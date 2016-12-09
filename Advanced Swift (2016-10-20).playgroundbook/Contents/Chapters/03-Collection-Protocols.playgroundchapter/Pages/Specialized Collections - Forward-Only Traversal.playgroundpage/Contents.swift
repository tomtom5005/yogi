/*:
### Forward-Only Traversal

A singly linked list is famous for a particular trait: it can only be iterated
forward. You can't leap into the middle of a linked list. You can't start at the
end and work backward. You can only go forward.

For this reason, while our `List` collection has a `first` property, it doesn't
have a `last` property. To get the last element of a list, you have to iterate
all the way to the end, an `O(n)` operation. It would be misleading to provide a
cute little property for the last element — a list with a million elements takes
a long time to fetch the last element.

A general rule of thumb for properties is probably that "they must be
constant-time(-ish) operations only, unless it's incredibly obvious the
operation couldn't be done in constant time." This is quite a wooly definition.
"Must be constant-time operations" would be nicer, but the standard library does
make some exceptions. For example, the default implementation of the `count`
property is documented to be `O(n)`, though most collections will provide an
overload that guarantees `O(1)`, like we did above for `List`.

Functions are a different matter. Our `List` type *does* have a `reversed`
operation:

*/

//#-hidden-code
/// Private implementation detail of the List collection
fileprivate enum ListNode<Element> {
    case end
    indirect case node(Element, next: ListNode<Element>)

    func cons(_ x: Element) -> ListNode<Element> {
        return .node(x, next: self)
    }
}
//#-end-hidden-code

//#-hidden-code
public struct ListIndex<Element>: CustomStringConvertible {
    fileprivate let node: ListNode<Element>
    fileprivate let tag: Int

    public var description: String {
       return "ListIndex(\(tag))"
    }
}
//#-end-hidden-code

//#-hidden-code
extension ListIndex: Comparable {
    public static func == <T>(lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
        return lhs.tag == rhs.tag
    }

    public static func < <T>(lhs: ListIndex<T>, rhs: ListIndex<T>) -> Bool {
        // startIndex has the highest tag, endIndex the lowest
        return lhs.tag > rhs.tag
    }
}
//#-end-hidden-code

//#-hidden-code
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
//#-end-hidden-code

//#-hidden-code
extension List: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        startIndex = ListIndex(node: elements.reversed().reduce(.end) { 
            partialList, element in
            partialList.cons(element)
        }, tag: elements.count)
        endIndex = ListIndex(node: .end, tag: 0)
    }
}
//#-end-hidden-code

//#-hidden-code
extension List: CustomStringConvertible {
    public var description: String {
        let elements = self.map { String(describing: $0) }
            .joined(separator: ", ")
        return "List: (\(elements))"
    }
}
//#-end-hidden-code

//#-editable-code
let list: List = ["red", "green", "blue"]
let reversed = list.reversed()
//#-end-editable-code

/*:
In this case, what's being called is the `reversed` method provided by the
standard library as an extension on `Sequence`, which returns the reversed
elements in an array:

``` swift-example
extension Sequence {
    /// Returns an array containing the elements of this sequence
    /// in reverse order. The sequence must be finite.
    func reversed() -> [Self.Iterator.Element]
}
```

*/

