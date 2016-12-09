/*:
## Slices

All collections get a default implementation of the slicing operation and have
an overload for `subscript` that takes a `Range<Index>`. This is the equivalent
of `list.dropFirst()`:

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
let list: List = [1,2,3,4,5]
let onePastStart = list.index(after: list.startIndex)
let firstDropped = list[onePastStart..<list.endIndex]
Array(firstDropped)
//#-end-editable-code

/*:
Since operations like `list[somewhere..<list.endIndex]` (slice from a specific
point to the end) and `list[list.startIndex..<somewhere]` (slice from the start
to a specific point) are very common, there are default operations in the
standard library that do this in a more readable way:

*/

//#-editable-code
let firstDropped2 = list.suffix(from: onePastStart)
//#-end-editable-code

/*:
By default, the type of `firstDropped` won't be a list — it'll be a
`Slice<List<String>>`. `Slice` is a lightweight wrapper on top of any
collection. The implementation looks something like this:

*/

//#-editable-code
struct Slice_sample_impl<Base: Collection>: Collection {
    typealias Index = Base.Index
    typealias IndexDistance = Base.IndexDistance
    
    let collection: Base

    var startIndex: Index
    var endIndex: Index

    init(base: Base, bounds: Range<Index>) {
        collection = base
        startIndex = bounds.lowerBound
        endIndex = bounds.upperBound
    }

    func index(after i: Index) -> Index {
        return collection.index(after: i)
    }

    subscript(position: Index) -> Base.Iterator.Element {
        return collection[position]
    }

    typealias SubSequence = Slice_sample_impl<Base>
    
    subscript(bounds: Range<Base.Index>) -> Slice_sample_impl<Base> {
        return Slice_sample_impl(base: collection, bounds: bounds)
    }
}
//#-end-editable-code

/*:
In addition to a reference to the original collection, `Slice` stores the start
and end index of the slice's bounds. This makes it twice as big as it needs to
be in `List`'s case, because the storage of a list itself consists of two
indices:

*/

//#-editable-code
// Size of a list is size of two nodes, the start and end:
MemoryLayout.size(ofValue: list)

// Size of a list slice is size of a list, plus size of the slice's
// start and end index, which in List's case are also list nodes.
MemoryLayout.size(ofValue: list.dropFirst())
//#-end-editable-code

