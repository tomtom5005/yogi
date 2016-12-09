/*:
## Conforming to `Collection`

We now have a container that can enqueue and dequeue elements. The next step is
to add `Collection` conformance to `FIFOQueue`. Unfortunately, figuring out the
minimum set of implementations you must provide to conform to a protocol can
sometimes be a frustrating experience in Swift.

At the time of writing, the `Collection` protocol has a whopping four associated
types, four properties, seven instance methods, and two subscripts:

``` swift-example
protocol Collection: Indexable, Sequence {
    associatedtype Iterator: IteratorProtocol = IndexingIterator<Self>
    associatedtype SubSequence: IndexableBase, Sequence = Slice<Self>
    associatedtype IndexDistance: SignedInteger = Int
    associatedtype Indices: IndexableBase, Sequence = DefaultIndices<Self>

    var first: Iterator.Element? { get }
    var indices: Indices { get }
    var isEmpty: Bool { get }
    var count: IndexDistance { get }

    func makeIterator() -> Iterator
    func prefix(through position: Index) -> SubSequence
    func prefix(upTo end: Index) -> SubSequence
    func suffix(from start: Index) -> SubSequence
    func distance(from start: Index, to end: Index) -> IndexDistance
    func index(_ i: Index, offsetBy n: IndexDistance) -> Index
    func index(_ i: Index, offsetBy n: IndexDistance, limitedBy limit: Index) -> Index?

    subscript(position: Index) -> Iterator.Element { get }
    subscript(bounds: Range<Index>) -> SubSequence { get }
}
```

It also inherits from `Sequence` and `Indexable`, so we need to add those
protocols' requirements to the "to-do list" of things we have to provide for our
custom type. Quite a daunting task, isn't it?

Well, it turns out it's actually not that bad. Notice that all associated types
have default values, so you don't need to care about those unless your type has
special requirements. The same is true for most of the functions, properties,
and subscripts: protocol extensions on `Collection` provide the default
implementations. Some of these extensions have associated type constraints that
match the protocol's default associated types; for example, `Collection` only
provides a default implementation of the `makeIterator` method if its `Iterator`
is an `IndexingIterator<Self>`:

``` swift-example
extension Collection where Iterator == IndexingIterator<Self> {
    /// Returns an iterator over the elements of the collection.
    func makeIterator() -> IndexingIterator<Self>
}
```

If you decide that your type should have a different iterator type, you'd have
to implement this method.

Working out what's required and what's provided through defaults isn't exactly
hard, but it's a lot of manual work, and unless you're very careful not to
overlook anything, it's easy to end up in an annoying guessing game with the
compiler. The most frustrating part of the process may be that the compiler
*has* all the information to guide you; the diagnostics just aren't helpful
enough yet.

For the time being, your best hope is to find the minimal conformance
requirements spelled out in the documentation, as is in fact the case for
`Collection`.

> **Conforming to the Collection Protocol**
> 
> … To add `Collection` conformance to your type, declare `startIndex` and
> `endIndex` properties, a subscript that provides at least read-only access to
> your type's elements, and the `index(after:)` method for advancing your
> collection's indices.

So in the end, we end up with these requirements:

``` swift-example
protocol Collection: Indexable, Sequence {
    /// A type that represents a position in the collection.
    associatedtype Index: Comparable
    /// The position of the first element in a nonempty collection.
    var startIndex: Index { get }
    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    var endIndex: Index { get }
    /// Returns the position immediately after the given index.
    func index(after i: Index) -> Index
    /// Accesses the element at the specified position.
    subscript(position: Index) -> Element { get }
}
```

From the original requirements of the `Collection` protocol, only the subscript
remains. The other requirements are inherited from `IndexableBase` by way of
`Indexable`. Both of these protocols should be considered implementation details
that only exist because of compiler limitations in Swift 3 (namely, the lack of
support for circular protocol constraints). We expect them to be removed in
Swift 4, with their functionality folded into `Collection`. You shouldn't need
to use these protocols directly.

We can conform `FIFOQueue` to `Collection` like so:

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
extension FIFOQueue: Collection {
    public var startIndex: Int { return 0 }
    public var endIndex: Int { return left.count + right.count }
    
    public func index(after i: Int) -> Int {
        precondition(i < endIndex)
        return i + 1
    }
    
    public subscript(position: Int) -> Element {
        precondition((0..<endIndex).contains(position), "Index out of bounds")
        if position < left.endIndex {
            return left[left.count - position - 1]
        } else {
            return right[position - left.count]
        }
    }
}
//#-end-editable-code

/*:
We use `Int` as our queue's `Index` type. We don't specify an explicit typealias
for the associated type; just like with `Element`, Swift can infer it from the
method and property definitions. Note that since the indexing returns elements
from the front first, `Queue.first` returns the next item that will be dequeued
(so it serves as a kind of peek).

With just a handful of lines, queues now have more than 40 methods and
properties at their disposal. We can iterate over queues:

*/

//#-editable-code
var q = FIFOQueue<String>()
for x in ["1", "2", "foo", "3"] {
    q.enqueue(x)
}

for s in q {
    print(s, terminator: " ")
}
//#-end-editable-code

/*:
We can pass queues to methods that take sequences:

*/

//#-editable-code
var a = Array(q)
a.append(contentsOf: q[2...3])
//#-end-editable-code

/*:
We can call methods and properties that extend `Sequence`:

*/

//#-editable-code
q.map { $0.uppercased() }
q.flatMap { Int($0) }
q.filter { $0.characters.count > 1 }
q.sorted()
q.joined(separator: " ")
//#-end-editable-code

/*:
And we can call methods and properties that extend `Collection`:

*/

//#-editable-code
q.isEmpty
q.count
q.first
//#-end-editable-code

