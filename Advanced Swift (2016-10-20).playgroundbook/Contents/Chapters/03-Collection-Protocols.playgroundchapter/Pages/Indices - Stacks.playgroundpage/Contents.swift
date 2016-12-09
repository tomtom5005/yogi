/*:
#### Stacks

This list is a stack, with consing as push, and unwrapping the next element as
pop. As we've mentioned before, arrays are also stacks. Let's define a common
protocol for stacks, as we did with queues:

*/

//#-editable-code
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
//#-end-editable-code

/*:
We've been a bit more proscriptive in the documentation comments about what it
means to conform to `Stack`, including giving some minimum performance
guarantees.

`Array` can be made to conform to `Stack`, like this:

*/

//#-editable-code
extension Array: Stack {
    mutating func push(_ x: Element) { append(x) }
    mutating func pop() -> Element? { return popLast() }
}
//#-end-editable-code

/*:
So can `List`:

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

//#-editable-code
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
//#-end-editable-code

/*:
But didn't we just say that the list had to be immutable for the persistence to
work? How can it have mutating methods?

These mutating methods don't change the list. Instead, they just change the part
of the list the variables refer to:

*/

//#-editable-code
var stack: List<Int> = [3,2,1]
var a = stack
var b = stack

a.pop()
a.pop()
a.pop()

stack.pop()
stack.push(4)

b.pop()
b.pop()
b.pop()

stack.pop()
stack.pop()
stack.pop()
//#-end-editable-code

/*:
This shows us the difference between values and variables. The nodes of the list
are values; they can't change. A node of three and a reference to the next node
can't become some other value; it'll be that value forever, just like the number
three can't change. It just is. Just because these values in question are
structures with references to each other doesn't make them less value-like.

A variable `a`, on the other hand, can change the value it holds. It can be set
to hold a value of an indirect reference to any of the nodes, or to the value
`end`. But changing `a` doesn't change these nodes; it just changes which node
`a` refers to.

This is what these mutating methods on structs do — they take an implicit
`inout` argument of `self`, and they can change the value `self` holds. This
doesn't change the list, but rather which part of the list the variable
currently represents. In this sense, through `indirect`, the variables have
become iterators into the list:

![List Iteration](artwork/list-iteration.png)

You can, of course, declare your variables with `let` instead of `var`, in which
case the variables will be constant (i.e. you can't change the value they hold
once they're set). But `let` is about the variables, not the values. Values are
constant by definition.

Now this is all just a logical model of how things work. In reality, the nodes
are actually places in memory that point to each other. And they take up space,
which we want back if it's no longer needed. Swift uses automated reference
counting (ARC) to manage this and frees the memory for the nodes that are no
longer used:

![List Memory Management](artwork/list-arc.png)

We'll discuss `inout` in more detail in the chapter on functions, and we'll
cover mutating methods as well as ARC in the structs and classes chapter.

*/
