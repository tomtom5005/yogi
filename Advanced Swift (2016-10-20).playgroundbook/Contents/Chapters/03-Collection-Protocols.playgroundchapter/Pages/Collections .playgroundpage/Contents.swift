/*:
## Collections 

A collection is a stable sequence that can be traversed nondestructively
multiple times. In addition to linear traversal, a collection's elements can
also be accessed via subscript with an index. Subscript indices are often
integers, as they are in arrays. But as we'll see, indices can also be opaque
values (as in dictionaries or strings), which sometimes makes working with them
non-intuitive. A collection's indices invariably form a finite range, with a
defined start and end. This means that unlike sequences, collections can't be
infinite.

The `Collection` protocol builds on top of `Sequence`. In addition to all the
methods inherited from `Sequence`, collections gain new capabilities that either
depend on accessing elements at specific positions or rely on the guarantee of
stable iteration, like the `count` property (if counting the elements of an
unstable sequence consumed the sequence, it would kind of defeat the purpose).

Even if you don't need the special features of a collection, you can use
`Collection` conformance to signal to users that your own sequence type is
finite and supports multi-pass iteration. It's somewhat strange that you have to
come up with an index if all you want is to document that your sequence is
multi-pass. Picking a suitable index type to represent positions in the
collection is often the hardest part of implementing the `Collection` protocol.
One reason for this design is that the Swift team wanted to avoid the potential
confusion of having a distinct [protocol for multi-pass
sequences](https://lists.swift.org/pipermail/swift-evolution/Week-of-Mon-20151228/004989.html)
that had requirements identical to `Sequence` but different semantics.

Collections are used extensively throughout the standard library. In addition to
`Array`, `Dictionary`, and `Set`, the four `String` views are all collections,
as are `CountableRange` and `UnsafeBufferPointer`. Increasingly, we're also
seeing types outside the standard library adopt the `Collection` protocol. Two
examples of types that gained a ton of new capabilities in this way are `Data`
and `IndexSet`, both from Foundation.

To demonstrate how collections in Swift work, we'll implement one of our own.
Probably the most useful container type not present in the Swift standard
library is a queue. Swift arrays are able to easily be used as stacks, with
`append` to push and `popLast` to pop. However, they're not ideal to use as
queues. You could use `push` combined with `remove(at: 0)`, but removing
anything other than the last element of an array is an `O(n)` operation —
because arrays are held in contiguous memory, every element has to shuffle down
to fill the gap (unlike popping the last element, which can be done in constant
time).

*/
