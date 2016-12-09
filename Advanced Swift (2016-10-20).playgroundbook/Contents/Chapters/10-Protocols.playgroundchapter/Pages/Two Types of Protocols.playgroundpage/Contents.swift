/*:
## Two Types of Protocols

As we stated in the introduction, protocols with associated types are different
from regular protocols. The same is true for protocols with a `Self`
requirement, i.e. those that refer to `Self` anywhere in their definition. In
Swift 3, these protocols can't be used as standalone types. This restriction
will probably be lifted in a future version once the full generics system is
implemented, but until then, we have to deal with the limitations.

One of the simplest examples of a protocol with an associated type is
`IteratorProtocol`. It has a single associated type, `Element`, and a single
function, `next()`, which returns a value of that type:

``` swift-example
public protocol IteratorProtocol {
    associatedtype Element
    public mutating func next() -> Self.Element?
}
```

In the chapter on collection protocols, we showed an example of a type that
conforms to `IteratorProtocol`. This iterator simply returns `1` each time it's
called:

*/

//#-editable-code
struct ConstantIterator: IteratorProtocol {
    mutating func next() -> Int? {
        return 1
    }
}
//#-end-editable-code

/*:
As we've seen, `IteratorProtocol` forms the base for the collection protocols.
Unlike `IteratorProtocol`, the `Collection` protocol doesn't have a simple
definition:

``` swift-example
protocol Collection: Indexable, Sequence {
    associatedtype IndexDistance: SignedInteger = Int
    associatedtype Iterator: IteratorProtocol = IndexingIterator<Self>
    // ... Method definitions and more associated types
}
```

Let's look at some of the important parts of the definition above. The
collection protocol inherits from `Indexable` and `Sequence`. Because protocol
inheritance doesn't have the same problems as inheritance through subclassing,
we can compose multiple protocols:

``` swift-example
protocol Collection: Indexable, Sequence {
```

Next up, we have two associated types: `IndexDistance` and `Iterator`. Both have
a default value: `IndexDistance` is just an `Int`, and `Iterator` is an
`IndexingIterator`. Note that we can use `Self` for the generic type parameter
of `IndexingIterator`. Both types also have constraints: `IndexDistance` needs
to conform to the `SignedInteger` protocol, and `Iterator` needs to conform to
`IteratorProtocol`:

``` swift-example
associatedtype IndexDistance: SignedInteger = Int
associatedtype Iterator: IteratorProtocol = IndexingIterator<Self>
```

There are two options when we make our own types conform to the `Collection`
protocol. We can either use the default associated types, or we could define our
own associated types (for example, in the collection protocols chapter, we made
`List` have a custom associated type for `SubSequence`). If we decide to stick
with the default associated types, we get a lot of functionality for free. For
example, there's a conditional protocol extension that adds an implementation of
`makeIterator()` when the iterator isn't overridden:

``` swift-example
extension Collection where Iterator == IndexingIterator<Self> {
    func makeIterator() -> IndexingIterator<Self>
}
```

There are many more conditional extensions, and you can also add your own. As we
mentioned earlier, it can be challenging to see which methods you should
implement in order to conform to a protocol. Because many protocols in the
standard library have default values for the associated types and conditional
extensions that match those associated types, you often only have to implement a
handful of methods, even for protocols that have dozens of requirements. To
address this, the standard library has documented it in a section, "Conforming
to the Sequence Protocol." If you write a custom protocol with more than a few
methods, you should consider adding a similar section to your documentation.

*/
