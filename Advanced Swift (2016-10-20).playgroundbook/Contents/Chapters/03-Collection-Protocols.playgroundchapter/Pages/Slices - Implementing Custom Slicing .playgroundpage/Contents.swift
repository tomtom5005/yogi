/*:
### Implementing Custom Slicing 

We can do better, because lists could instead return themselves as subsequences
by holding different start and end indices. We can give `List` a custom
implementation that does this:

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
    public subscript(bounds: Range<Index>) -> List<Element> {
        return List(startIndex: bounds.lowerBound, endIndex: bounds.upperBound)
    }
}
//#-end-editable-code

/*:
Using this implementation, list slices are themselves lists, so their size is
only 32 bytes:

*/

//#-editable-code
let list: List = [1,2,3,4,5]
MemoryLayout.size(ofValue: list.dropFirst())
//#-end-editable-code

/*:
Perhaps more important than the size optimization is that sequences and
collections that are their own subsequence type are more pleasant to work with
because you don't have to deal with another type. As one example, your carefully
designed `CustomStringConvertible` implementation will also work on a
subsequence without additional code.

Another thing to consider is that with many sliceable containers, including
Swift's arrays and strings, a slice shares the storage buffer of the original
collection. This has an unpleasant side effect: slices can keep the original
collection's buffer alive in its entirety, even if the original collection falls
out of scope. If you read a 1 GB file into an array or string, and then slice
off a tiny part, the whole 1 GB buffer will stay in memory until both the
collection and the slice are destroyed. This is why Apple explicitly warns [in
the documentation](https://developer.apple.com/reference/swift/slice) to "use
slices only for transient computation."

With `List`, it isn't quite as bad. As we've seen, the nodes are managed by ARC:
when the slices are the only remaining copy, any elements dropped from the front
will be reclaimed as soon as no one is referencing them:

![List Sharing and ARC](artwork/list-index-share.png)

![Memory Reclaiming](artwork/list-index-share2.png)

However, the back nodes won't be reclaimed, since the slice's last node still
has a reference to what comes after it:

![No Reclaiming of Memory](artwork/list-index-share3.png)

*/

