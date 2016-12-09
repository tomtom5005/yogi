/*:
## Sequences 

The `Sequence` protocol stands at the base of the hierarchy. A sequence is a
series of values of the same type that lets you iterate over the values. The
most common way to traverse a sequence is a `for` loop:

``` swift-example
for element in someSequence {
    doSomething(with: element)
}
```

This seemingly simple capability of stepping over elements forms the foundation
for a large number of useful operations `Sequence` provides to adopters of the
protocol. We already mentioned many of them in the previous chapter. Whenever
you come up with a common operation that depends on sequential access to a
series of values, you should consider implementing it on top of `Sequence`, too.
We'll see many examples of how to do this throughout this chapter and the rest
of the book.

The requirements for a type to conform to `Sequence` are fairly small. All it
must do is provide a `makeIterator()` method that returns an *iterator*:

``` swift-example
protocol Sequence {
    associatedtype Iterator: IteratorProtocol
    func makeIterator() -> Iterator
}
```

The only thing we learn about iterators from the definition of `Sequence` is
that they're types that conform to `IteratorProtocol`. So let's first take a
closer look at them.

*/
