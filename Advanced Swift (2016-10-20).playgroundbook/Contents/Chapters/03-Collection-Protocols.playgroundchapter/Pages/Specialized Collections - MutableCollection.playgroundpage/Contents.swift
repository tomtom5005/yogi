/*:
### MutableCollection

A mutable collection supports in-place element mutation. The single new
requirement it adds to `Collection` is that the `subscript` now must also have a
setter. We can't make `List` mutable, but we can add conformance to our queue
type:

*/

//#-hidden-code
/// A type that can `enqueue` and `dequeue` elements.
protocol Queue {
    /// The type of elements held in `self`.
    associatedtype Element
    /// Enqueue `element` to `self`.
    mutating func enqueue(_ newElement: Element)
    /// Dequeue an element from `self`.
    mutating func dequeue() -> Element?
}
//#-end-hidden-code

//#-hidden-code
/// An efficient variable-size FIFO queue of elements of type `Element`
struct FIFOQueue<Element>: Queue {
    fileprivate var left: [Element] = []
    fileprivate var right: [Element] = []

    /// Add an element to the back of the queue.
    /// - Complexity: O(1).
    mutating func enqueue(_ newElement: Element) {
        right.append(newElement)
    }

    /// Removes front of the queue.
    /// Returns `nil` in case of an empty queue.
    /// - Complexity: Amortized O(1).
    mutating func dequeue() -> Element? {
        if left.isEmpty {
            left = right.reversed()
            right.removeAll()
        }
        return left.popLast()
    }
}
//#-end-hidden-code

//#-editable-code
extension FIFOQueue: MutableCollection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return left.count + right.count }
    
    public func index(after i: Int) -> Int {
        return i + 1
    }
    
    public subscript(position: Int) -> Element {
        get {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                return left[left.count - position - 1]
            } else {
                return right[position - left.count]
            }
        }
        set {
            precondition((0..<endIndex).contains(position), "Index out of bounds")
            if position < left.endIndex {
                left[left.count - position - 1] = newValue
            } else {
                return right[position - left.count] = newValue
            }
        }
    }
}
//#-end-editable-code

//#-hidden-code
extension FIFOQueue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        self.init(left: elements.reversed(), right: [])
    }
}
//#-end-hidden-code

/*:
Notice that the compiler won't let us add the subscript setter in an extension
to an existing `Collection`; it's neither allowed to provide a setter without a
getter, nor can we redefine the existing getter, so we have to replace the
existing `Collection`-conforming extension. Now the queue is mutable via
subscripts:

*/

//#-editable-code
var playlist: FIFOQueue = ["Shake It Off", "Blank Space", "Style"]
playlist.first
swap(&playlist[0], &playlist[1])
playlist.first
//#-end-editable-code

/*:
Relatively few types in the standard library adopt `MutableCollection`. Of the
three major collection types, only `Array` does. `MutableCollection` allows
changing the values of a collection's elements but not the length of the
collection or the order of the elements. This last point explains why
`Dictionary` and `Set` do *not* conform to `MutableCollection`, although they're
certainly mutable data structures.

Dictionaries and sets are *unordered* collections — the order of the elements is
undefined as far as the code using the collection is concerned. However,
*internally* , even these collections have a stable element order that's defined
by their implementation. When you mutate a `MutableCollection` via subscript
assignment, the index of the mutated element must remain stable, i.e. the
position of the index in the `indices` collection must not change. `Dictionary`
and `Set` can't satisfy this requirement because their indices point to the
bucket in their internal storage where the corresponding element is stored, and
that bucket could change when the element is mutated.

*/
