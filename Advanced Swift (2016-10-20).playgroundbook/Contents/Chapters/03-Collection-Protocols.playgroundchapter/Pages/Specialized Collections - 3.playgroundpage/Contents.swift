/*:
But you might want to be able to stick with a list as the reverse of a list — in
which case, we can overload the default implementation by extending `List`:

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
extension List {
    public func reversed() -> List<Element> {
        let reversedNodes: ListNode<Element> = 
            self.reduce(.end) { $0.cons($1) }
        return List(
            startIndex: ListIndex(node: reversedNodes, tag: self.count),
            endIndex: ListIndex(node: .end, tag: 0))
    }
}
//#-end-editable-code

/*:
Now, when you call `reversed` on a list, you get another list. This will be
chosen by default by Swift's overloading resolution mechanism, which always
favors the most specialized implementation of a function or method on the basis
that this almost always means it's a better choice. In this case, an
implementation of `reversed` directly on `List` is more specific than the more
general one that reverses any sequence:

*/

//#-editable-code
let list: List = ["red", "green", "blue"]
let reversed = list.reversed()
//#-end-editable-code

/*:
But it's possible you really want an array, in which case it'd be more efficient
to use the sequence-reversing version rather than reversing the list and then
converting it to an array in two steps. If you still wanted to choose the
version that returns an array, you could force Swift to call it by specifying
the type you're assigning to (rather than letting type inference default it for
you):

*/

//#-editable-code
let reversedArray: [String] = list.reversed()
//#-end-editable-code

/*:
Or, you can use the `as` keyword if you pass the result into a function. For
example, the following code tests that calling `reversed` on a list generates
the same result as the version on an array:

*/

//#-editable-code
list.reversed().elementsEqual(list.reversed() as [String])
//#-end-editable-code

/*:
A quick testing tip: be sure to check that the overload is really in place and
not accidentally missing. Otherwise, the above test will always pass, because
you'll be comparing the two array versions.

You can test for this using `is List`, but assuming the overload is working, the
compiler will warn you that your `is` is pointless (which would be true, so long
as your overload has worked). To avoid that, you can cast via `Any` first:

*/

//#-editable-code
list.reversed() as Any is List<String>
//#-end-editable-code

