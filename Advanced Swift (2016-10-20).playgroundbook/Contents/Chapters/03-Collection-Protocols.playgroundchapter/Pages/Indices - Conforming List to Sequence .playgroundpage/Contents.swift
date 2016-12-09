/*:
#### Conforming `List` to `Sequence` 

Since list variables are iterators into the list, this means you can use them to
conform `List` to `Sequence`. As a matter of fact, `List` is an example of an
unstable sequence that carries its own iteration state, like we saw when we
talked about the relationship between sequences and iterators. We can add
conformance to `IteratorProtocol` and `Sequence` in one go just by providing a
`next()` method; the implementation of this is exactly the same as for `pop`:

*/

//#-hidden-code
/// A simple linked list enum
enum List<Element> {
    case end
    indirect case node(Element, next: List<Element>)
}
//#-end-hidden-code

//#-hidden-code
extension List {
    /// Return a new list by prepending a node with value `x` to the
    /// front of a list.
    func cons(_ x: Element) -> List {
        return .node(x, next: self)
    }
}
//#-end-hidden-code

//#-hidden-code
extension List: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self = elements.reversed().reduce(.end) { partialList, element in
            partialList.cons(element)
        }
    }
}
//#-end-hidden-code

//#-hidden-code
/// A LIFO stack type with constant-time push and pop operations
protocol Stack {
    /// The type of element held stored in the stack
    associatedtype Element

    /// Pushes `x` onto the top of `self`
    /// - Complexity: Amortized O(1).
    mutating func push(_: Element)

    /// Removes the topmost element of `self` and returns it,
    /// or `nil` if `self` is empty.
    /// - Complexity: O(1)
    mutating func pop() -> Element?
}
//#-end-hidden-code

//#-hidden-code
extension List: Stack {
    mutating func push(_ x: Element) {
        self = self.cons(x)
    }

    mutating func pop() -> Element? {
        switch self {
        case .end: return nil
        case let .node(x, next: xs):
            self = xs
            return x
        }
    }
}
//#-end-hidden-code

//#-editable-code
extension List: IteratorProtocol, Sequence {
    mutating func next() -> Element? {
        return pop()
    }
}
//#-end-editable-code

/*:
Now you can use lists with `for ... in`:

*/

//#-editable-code
let list: List = ["1", "2", "3"]
for x in list {
    print("\(x) ", terminator: "")
}
//#-end-editable-code

/*:
This also means that, through the power of protocol extensions, we can use
`List` with dozens of standard library functions:

*/

//#-editable-code
list.joined(separator: ",")
list.contains("2")
list.flatMap { Int($0) }
list.elementsEqual(["1", "2", "3"])
//#-end-editable-code
