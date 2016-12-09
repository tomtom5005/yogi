/*:
### Associated Types

We've seen that `Collection` provides defaults for all but one of its associated
types; types adopting the protocol only have to specify an `Index` type. While
you don't *have* to care much about the other associated types, it's a good idea
to take a brief look at each of them in order to better understand what they do.
Let's go through them one by one.

**`Iterator`.** Inherited from `Sequence`. We already looked at iterators in
detail in our discussion on sequences. The default iterator type for collections
is `IndexingIterator<Self>`. This is a simple struct that wraps the collection
and uses the collection's own indices to step over each element. The
[implementation](https://github.com/apple/swift/blob/master/stdlib/public/core/Collection.swift#L360-L407)
is straightforward:

``` swift-example
struct IndexingIterator<Elements: IndexableBase>: IteratorProtocol, Sequence {
    private let _elements: Elements
    private var _position: Elements.Index

    init(_elements: Elements) {
        self._elements = _elements
        self._position = _elements.startIndex
    }

    mutating func next() -> Elements._Element? {
        guard _position < _elements.endIndex else {
            return nil
        }
        let element = _elements[_position]
        _elements.formIndex(after: &_position)
        return element
    }
}
```

(The generic constraint `<Elements: IndexableBase>` should really be `<Elements:
Collection>` once the compiler allows circular associated type constraints.)

Most collections in the standard library use `IndexingIterator` as their
iterator. There should be little reason to write your own iterator type for a
custom collection.

**`SubSequence`.** Also inherited from `Sequence`, but `Collection` restates
this type with tighter constraints. A collection's `SubSequence` should itself
also be a `Collection`. (We say "should" rather than "must" because this
constraint is currently not fully expressible in the type system.) The default
is `Slice<Self>`, which wraps the original collection and stores the slice's
start and end index in terms of the base collection.

It can make sense for a collection to customize its `SubSequence` type,
especially if it can be `Self` (i.e. a slice of the collection has the same type
as the collection itself). We'll talk more about slicing later in this chapter.

**`IndexDistance`.** A signed integer type that represents the number of steps
between two indices. There should be no reason to change this from the default
`Int`.

**`Indices`.** The return type of the collection's `indices` property. It
represents a collection containing all indices that are valid for subscripting
the base collection, in ascending order. Note that the `endIndex` is not
included because it signifies the "past the end" position and thus is not a
valid subscript argument.

In Swift 2, the `indices` property returned a `Range<Index>` that could be used
to iterate over all valid indices in the collection. In Swift 3, `Range<Index>`
is no longer iterable because indices can no longer be advanced on their own;
it's now up to the collection to advance an index. The `Indices` type replaces
`Range<Index>` to keep index iterations working.

The default type is the imaginatively named `DefaultIndices<Self>`. Like
`Slice`, it's a pretty simple wrapper for the base collection and a start and
end index — it needs to keep a reference to the base collection to be able to
advance the indices. This can lead to unexpected performance problems if users
mutate the collection while iterating over its indices: if the collection is
implemented using copy-on-write (as all collections in the standard library
are), the extra reference to the collection can trigger unnecessary copies.

We cover copy-on-write in the chapter on structs and classes. For now, it's
enough to know that if your custom collection can provide an alternative
`Indices` type that doesn't need to keep a reference to the base collection,
doing so is a worthwhile optimization. This is true for all collections whose
index math doesn't rely on the collection itself, like arrays or our queue. If
your index is an integer type, you can use `CountableRange<Index>`:

``` swift-example
extension FIFOQueue: Collection {
    ...
    typealias Indices = CountableRange<Int>
    var indices: CountableRange<Int> {
        return startIndex..<endIndex
    }
}
```

*/
