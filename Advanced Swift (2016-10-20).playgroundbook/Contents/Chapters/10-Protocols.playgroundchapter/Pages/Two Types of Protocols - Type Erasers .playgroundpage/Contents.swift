/*:
### Type Erasers 

In the previous section, we were able to use the `Drawing` protocol as a type.
However, with `IteratorProtocol`, this isn't (yet) possible, because it has an
associated type. The compile error says: "Protocol 'IteratorProtocol' can only
be used as a generic constraint because it has Self or associated type
requirements."

``` swift-example
let iterator: IteratorProtocol = ConstantIterator() // Error
```

In a way, `IteratorProtocol` used as a type is incomplete; we'd have to specify
the associated type as well in order for this to be meaningful.

> The Swift Core Team has stated that they want to support *generalized
> existentials*. This feature would allow for using protocols with associated
> types as standalone values, and it would also eliminate the need to write type
> erasers. For more information about what to expect in the future, see the
> [Swift Generics
> Manifesto](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20160229/011666.html).

In a future version of Swift, we might be able to solve this by saying something
like the following:

``` swift-example
let iterator: Any<IteratorProtocol where .Element == Int> = ConstantIterator()
```

Currently, we can't yet express this. We can, however, use `IteratorProtocol` as
a constraint for a generic parameter:

*/

//#-editable-code
func nextInt<I: IteratorProtocol>(iterator: inout I) -> Int?
    where I.Element == Int {
        return iterator.next()
}
//#-end-editable-code

/*:
Similarly, we can store an iterator in a class or struct. The limitation is the
same, in that we can only use it as a generic constraint, and not as a
standalone type:

*/

//#-editable-code
class IteratorStore<I: IteratorProtocol> where I.Element == Int {
    var iterator: I

    init(iterator: I) {
        self.iterator = iterator
    }
}
//#-end-editable-code

/*:
This works, but it has a drawback: the specific type of the stored iterator
"leaks out" through the generic parameter. In the current type system, we can't
express "any iterator, as long as the element type is `Int`." This is a problem
if you want to, for example, put multiple `IteratorStore`s into an array. All
elements in an array must have the same type, and that includes any generic
parameters; it's not possible to create an array that can store both
`IteratorStore<ConstantIterator>` and `IteratorStore<FibsIterator>`.

Luckily, there are two ways around this — one is easy, the other one more
efficient (but hacky). The process of removing a specific type (such as the
iterator) is called *type erasure*.

In the easy solution, we implement a wrapper class. Instead of storing the
iterator directly, the class stores the iterator's `next` function. To do this,
we must first copy the `iterator` parameter to a `var` variable so that we're
allowed to call its `next` method (which is `mutating`). We then wrap the call
to `next()` in a closure expression and assign that closure to a property. We
used a class to signal that `IntIterator` has reference semantics:

*/

//#-editable-code
class IntIterator {
    var nextImpl: () -> Int?

    init<I: IteratorProtocol>(_ iterator: I) where I.Element == Int {
        var iteratorCopy = iterator
        self.nextImpl = { iteratorCopy.next() }
    }
}
//#-end-editable-code

/*:
Now, in our `IntIterator`, the specific type of the iterator (e.g.
`ConstantIterator`) is only specified when creating a value. After that, the
specific type is hidden, captured by the closure. We can create an `IntIterator`
with any kind of iterator, as long as the elements are integers:

*/

//#-hidden-code
struct ConstantIterator: IteratorProtocol {
    mutating func next() -> Int? {
        return 1
    }
}
//#-end-hidden-code

//#-editable-code
var iter = IntIterator(ConstantIterator())
iter = IntIterator([1,2,3].makeIterator())
//#-end-editable-code

/*:
The code above allows us to specify the associated type constraints (e.g. `iter`
contains an iterator with `Int` elements) using Swift's current type system. Our
`IntIterator` can also easily conform to the `IteratorProtocol` (and the
inferred associated type is `Int`):

*/

//#-editable-code
extension IntIterator: IteratorProtocol {
    func next() -> Int? {
        return nextImpl()
    }
}
//#-end-editable-code

/*:
In fact, by abstracting over `Int` and adding a generic parameter, we can change
`IntIterator` to work just like `AnyIterator` does:

*/

//#-editable-code
class AnyIterator<A>: IteratorProtocol {
    var nextImpl: () -> A?

    init<I: IteratorProtocol>(_ iterator: I) where I.Element == A {
        var iteratorCopy = iterator
        self.nextImpl = { iteratorCopy.next() }
    }

    func next() -> A? {
        return nextImpl()
    }
}
//#-end-editable-code

/*:
The specific iterator type (`I`) is only specified in the initializer, and after
that, it's "erased."

From this refactoring, we can come up with a simple algorithm for creating a
type eraser. First, we create a struct or class named `AnyProtocolName`. Then,
for each associated type, we add a generic parameter. Finally, for each method,
we store the implementation in a property on `AnyProtocolName`.

For a simple protocol like `IteratorProtocol`, this only takes a few lines of
code, but for more complex protocols (such as `Sequence`), this is quite a lot
of work. Even worse, the size of the object or struct will increase linearly
with each protocol method (because a new closure is added for each method).

*/
