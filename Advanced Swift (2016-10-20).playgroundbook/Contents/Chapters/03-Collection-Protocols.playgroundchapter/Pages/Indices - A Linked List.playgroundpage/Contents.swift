/*:
### A Linked List

As an example of a collection that doesn't have an integer index, let's
implement one of the most basic collections of all: a singly linked list. To do
this, we'll first demonstrate another way of implementing data structures using
an indirect enum.

A linked list node is one of either two things: a node with a value and a
reference to the next node, or a node indicating the end of the list. We can
define it like this:

*/

//#-editable-code
/// A simple linked list enum
enum List<Element> {
    case end
    indirect case node(Element, next: List<Element>)
}
//#-end-editable-code

/*:
The use of the `indirect` keyword here indicates that the compiler should
represent this value as a reference. Swift enums are value types. This means
they hold their values directly in the variable, rather than the variable
holding a reference to the location of the value. This has many benefits, as
we'll see in the structs and classes chapter, but it also means they can't
contain a reference to themselves. The `indirect` keyword allows an enum case to
be held as a reference and thus hold a reference to itself.

We prepend another element to the list by creating a new node, with the `next:`
value set to the current node. To make this a little easier, we can create a
method for it. We name this prepending method `cons`, because that's the name of
the operation in LISP (it's short for "construct," and adding elements onto the
front of the list is sometimes called "consing"):

*/

//#-editable-code
extension List {
    /// Return a new list by prepending a node with value `x` to the
    /// front of a list.
    func cons(_ x: Element) -> List {
        return .node(x, next: self)
    }
}
//#-end-editable-code

//#-editable-code
// A 3-element list, of (3 2 1)
let list = List<Int>.end.cons(1).cons(2).cons(3)
//#-end-editable-code

/*:
The chaining syntax makes it clear how a list is constructed, but it's also kind
of ugly. As with our queue type, we can add conformance to
`ExpressibleByArrayLiteral` to be able to initialize a list with an array
literal. The implementation first reverses the input array (because lists are
built from the end) and then uses `reduce` to prepend the elements to the list
one by one, starting with the `.end` node:

*/

//#-editable-code
extension List: ExpressibleByArrayLiteral {
    init(arrayLiteral elements: Element...) {
        self = elements.reversed().reduce(.end) { partialList, element in
            partialList.cons(element)
        }
    }
}
//#-end-editable-code

//#-editable-code
let list2: List = [3,2,1]
//#-end-editable-code

/*:
This list type has an interesting property: it's
"[persistent](https://en.wikipedia.org/wiki/Persistent_data_structure)." The
nodes are immutable — once created, you can't change them. Consing another
element onto the list doesn't copy the list; it just gives you a new node that
links onto the front of the existing list.

This means two lists can share a tail:

![List Sharing](artwork/list-share.png)

The immutability of the list is key here. If you could change the list (say,
remove the last entry, or update the element held in a node), then this sharing
would be a problem — `x` might change the list, and the change would affect `y`.

*/
