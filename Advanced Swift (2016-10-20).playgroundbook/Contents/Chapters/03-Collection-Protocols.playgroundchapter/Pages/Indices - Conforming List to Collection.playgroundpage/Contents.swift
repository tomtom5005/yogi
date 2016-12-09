/*:
#### Conforming `List` to `Collection`

Next, we make `List` conform to `Collection`. To do that, we need to decide on
an index type for `List`. We said above that the best index is often a simple
integer offset into the collection's storage, but that doesn't work in this case
because a linked list has no contiguous storage. An integer-based index (e.g.
the number of steps to the node from the beginning of the list) would have to
traverse the list from the `startIndex` every time, making subscript access an
`O(n)` operation. However, [the documentation for
`Collection`](https://developer.apple.com/reference/swift/collection) requires
this to be `O(1)`, "because many collection operations depend on `O(1)`
subscripting performance for their own performance guarantees."

As a result, our index must reference the list nodes directly. This isn't a
problem for performance, because `List`, being immutable, doesn't use
copy-on-write optimizations.

Since we already used `List` directly as an iterator, it's tempting to do the
same here and use the enum itself as the index. But this will lead to problems.
For example, index and collection need very different implementations of `==`:

  - The index needs to know if two indices from the same list are at the same
    position. It shouldn't need the elements to conform to `Equatable`.

  - The collection, on the other hand, should be able to compare two different
    lists to see if they hold the same elements. It'll need the elements to
    conform to `Equatable`.

By creating separate types to represent the index and collection, we'll be able
to implement different behavior for the two different `==` operators. And by
having neither be the node enum, we'll be able to make that node implementation
private, hiding the details from users of the collection. The new `ListNode`
type looks just like our first variant of `List`:

*/

//#-editable-code
/// Private implementation detail of the List collection
fileprivate enum ListNode<Element> {
    case end
    indirect case node(Element, next: ListNode<Element>)

    func cons(_ x: Element) -> ListNode<Element> {
        return .node(x, next: self)
    }
}
//#-end-editable-code

/*:
The index type wraps `ListNode`. In order to be a collection index, a type needs
to conform to `Comparable`, which has only two requirements: it needs a
less-than operator (`<`), and it needs an is-equal operator (`==`), which the
protocol inherits from `Equatable`. The other operators, `>`, `<=`, and `>=`,
have default implementations like the first two do.

We need some additional information to allow us to implement `==` and `<`. As
we've discussed, nodes are values, and values don't have identity. So how can we
tell if two variables are pointing to the same node? To do this, we tag each
index with an incrementing number (the `.end` node has the tag zero). As we'll
see in a bit, storing the tags with the nodes will allow for very efficient
operations. The way the list works, two indices in the same list must be the
same if they have the same tag:

*/

//#-editable-code
public struct ListIndex<Element>: CustomStringConvertible {
    fileprivate let node: ListNode<Element>
    fileprivate let tag: Int

    public var description: String {
       return "ListIndex(\(tag))"
    }
}
//#-end-editable-code

/*:
Another thing to note is that `ListIndex` is a public struct but has private
properties (`node` and `tag`). This means it's not publicly constructible — its
default memberwise initializer of `ListIndex(node:tag:)` won't be accessible to
users. So you can be handed a `ListIndex` from a `List`, but you can't create
one yourself. This is a useful technique for hiding implementation details and
providing safety.

We also need to adopt `Comparable`. As we discussed above, we do this by
comparing the tag:

*/

//#-editable-code
extension ListIndex: Comparable {
    public static func == <T>(lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
        return lhs.tag == rhs.tag
    }

    public static func < <T>(lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
        // startIndex has the highest tag, endIndex the lowest
        return lhs.tag > rhs.tag
    }
}
//#-end-editable-code

/*:
Now that we have a suitable index type, the next step is to create a `List`
struct that conforms to `Collection`:

*/

//#-editable-code
public struct List<Element>: Collection {
    // Index's type could be inferred, but it helps make the rest of
    // the code clearer:
    public typealias Index = ListIndex<Element>

    public let startIndex: Index
    public let endIndex: Index

    public subscript(position: Index) -> Element {
        switch position.node {
        case .end: fatalError("Subscript out of range")
        case let .node(x, _): return x
        }
    }

    public func index(after idx: Index) -> Index {
        switch idx.node {
        case .end: fatalError("Subscript out of range")
        case let .node(_, next): return Index(node: next, tag: idx.tag - 1)
        }
    }
}
//#-end-editable-code

/*:
Note that `List` requires no other storage besides the `startIndex` and
`endIndex`. Since the index wraps the list node and the nodes link to each
other, the entire list is accessible from `startIndex`. And `endIndex` will be
the same `ListIndex(node: .end, tag: 0)` for all instances (at least until we
get to slicing, below).

To make lists easier to construct, we again implement
`ExpressibleByArrayLiteral`:

*/

//#-editable-code
extension List: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        startIndex = ListIndex(node: elements.reversed().reduce(.end) { 
            partialList, element in
            partialList.cons(element)
        }, tag: elements.count)
        endIndex = ListIndex(node: .end, tag: 0)
    }
}
//#-end-editable-code

/*:
The capabilities inherited from `Sequence` also make it very easy to write a
simple implementation of `description` for nicer debug output. We map over the
list elements, convert them to their string representations, and join them into
a single string:

*/

//#-editable-code
extension List: CustomStringConvertible {
    public var description: String {
        let elements = self.map { String(describing: $0) }
            .joined(separator: ", ")
        return "List: (\(elements))"
    }
}
//#-end-editable-code

/*:
And now our list gains the extensions on `Collection`:

*/

//#-editable-code
let list: List = ["one", "two", "three"]
list.first
list.index(of: "two")
//#-end-editable-code

/*:
As an added bonus, since the `tag` is the count of nodes prepended to `.end`,
`List` gets a constant-time `count` property, even though this is normally an
`O(n)` operation for a linked list:

*/

//#-editable-code
extension List {
    public var count: Int {
        return startIndex.tag - endIndex.tag
    }
}
list.count
//#-end-editable-code

/*:
The subtraction of the end index (which, up until now, will always be a tag of
zero) is to support slicing, which we'll come to shortly.

Finally, since `List` and `ListIndex` are two different types, we can give
`List` a different implementation of `==` — this time, comparing the elements:

*/

//#-editable-code
public func == <T: Equatable>(lhs: List<T>, rhs: List<T>) -> Bool {
    return lhs.elementsEqual(rhs)
}
//#-end-editable-code

/*:
In a perfect type system, we wouldn't just implement the overload for `==`, but
also add `Equatable` conformance to `List` itself, with a constraint that the
`Element` type must be `Equatable`, like so:

``` swift-example
extension List: Equatable where Element: Equatable { }
// Error: Extension of type 'List' with constraints cannot have an inheritance clause
```

This would allow us to compare a list of lists, for example, or use `List` in
any other place that requires `Equatable` conformance. Sadly, the language
currently can't express this kind of constraint. However, *conditional protocol
conformance* is a highly anticipated feature, and it's very likely to come with
Swift 4.

*/
