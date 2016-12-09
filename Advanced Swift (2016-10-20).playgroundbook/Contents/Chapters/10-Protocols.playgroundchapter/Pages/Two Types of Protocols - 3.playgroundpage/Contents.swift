/*:
The standard library takes a different approach to erasing types. We start by
creating a simple class that conforms to `IteratorProtocol`. Its generic type is
the `Element` of the iterator, and the implementation will simply crash:

*/

//#-editable-code
class IteratorBox<A>: IteratorProtocol {
    func next() -> A? {
        fatalError("This method is abstract.")
    }
}
//#-end-editable-code

/*:
Then, we create another class, `IteratorBoxHelper`, which is also generic. Here,
the generic parameter is the specific iterator type (for example,
`ConstantIterator`). The `next` method simply forwards to the `next` method of
the underlying iterator:

``` swift-example
class IteratorBoxHelper<I: IteratorProtocol> {
    var iterator: I
    init(iterator: I) {
        self.iterator = iterator
    }

    func next() -> I.Element? {
        return iterator.next()
    }
}
```

Now for the hacky part. We change `IteratorBoxHelper` so that it's a subclass of
`IteratorBox`, and the two generic parameters are constrained in such a way that
`IteratorBox` gets `I`'s element as the generic parameter:

*/

//#-editable-code
class IteratorBoxHelper<I: IteratorProtocol>: IteratorBox<I.Element> {
    var iterator: I
    init(_ iterator: I) {
        self.iterator = iterator
    }

    override func next() -> I.Element? {
        return iterator.next()
    }
}
//#-end-editable-code

/*:
This allows us to create a value of `IteratorBoxHelper` and use it as an
`IteratorBox`, effectively erasing the type of `I`:

*/

//#-hidden-code
struct ConstantIterator: IteratorProtocol {
    mutating func next() -> Int? {
        return 1
    }
}
//#-end-hidden-code

//#-editable-code
let iter: IteratorBox<Int> = IteratorBoxHelper(ConstantIterator())
//#-end-editable-code

/*:
In the standard library, the `IteratorBox` and `IteratorBoxHelper` are then made
private, and yet another wrapper (`AnyIterator`) makes sure that these
implementation details are hidden from the public interface.

*/
