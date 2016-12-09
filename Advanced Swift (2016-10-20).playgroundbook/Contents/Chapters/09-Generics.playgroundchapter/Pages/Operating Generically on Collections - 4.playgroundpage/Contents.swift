/*:
So how can we write a generic version of this that doesn't mandate integer
indices? Just like with binary search, we still need random access, but we also
have a new requirement that the collection be mutable, since we want to be able
to provide an in-place version. The use of `count - 1` will definitely need to
change in a way similar to the binary search.

Before we get to the generic implementation, there's an extra complication. We
want to use `arc4random_uniform` to generate random numbers, but we don't know
exactly what type of integer `IndexDistance` will be. We know it's an integer,
but not necessarily that it's an `Int`.

> Swift's current integer APIs aren't well suited for generic programming. A
> [proposal for revised integer
> protocols](https://github.com/apple/swift-evolution/blob/master/proposals/0104-improved-integers.md)
> that would improve this considerably has been accepted, but it wasn't
> implemented in time for Swift 3.0.

To handle this, we need to use `numericCast`, which is a function for converting
generically between different integer types. Using this, we can write a version
of `arc4random_uniform` that works on any signed integer type (we could write a
version for unsigned integer types too, but since index distances are always
signed, we don't need to):

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
extension SignedInteger {
    static func arc4random_uniform(_ upper_bound: Self) -> Self {
        precondition(upper_bound > 0 &&
            upper_bound.toIntMax() < UInt32.max.toIntMax(),
            "arc4random_uniform only callable up to \(UInt32.max)")
        return numericCast(
            Darwin.arc4random_uniform(numericCast(upper_bound)))
    }
}
//#-end-editable-code

/*:
> You could write a version of `arc4random` that operates on ranges spanning
> negative numbers, or above the max of `UInt32`, if you wanted to. But to do so
> would require a lot more code. If you're interested, the definition of
> `arc4random_uniform` is actually [open
> source](http://www.opensource.apple.com/source/Libc/Libc-594.9.4/gen/FreeBSD/arc4random.c)
> and quite well commented, and it gives several clues as to how you might do
> this.

We then use the ability to generate a random number for every `IndexDistance`
type in our generic shuffle implementation:

*/

//#-editable-code
extension MutableCollection where Self: RandomAccessCollection {
    mutating func shuffle() {
        var i = startIndex
        let beforeEndIndex = index(before: endIndex)
        while i < beforeEndIndex {
            let dist = distance(from: i, to: endIndex)
            let randomDistance = IndexDistance.arc4random_uniform(dist)
            let j = index(i, offsetBy: randomDistance)
            guard i != j else { continue }
            swap(&self[i], &self[j])
            formIndex(after: &i)
        }
    }
}

extension Sequence {
    func shuffled() -> [Iterator.Element] {
        var clone = Array(self)
        clone.shuffle()
        return clone
    }
}

var numbers = Array(1...10)
numbers.shuffle()
numbers
//#-end-editable-code


/*:
The `shuffle` method is significantly more complex and less readable than the
non-generic version. This is partly because we had to replace simple integer
math like `count - 1` with index calculations such as `index(before: endIndex)`.
The other reason is that we switched from a `for` to a `while` loop. The
alternative, iterating over the indices with `for i in indices.dropLast()`, has
a potential performance problem that we already talked about in the collection
protocols chapter: if the `indices` property holds a reference to the
collection, mutating the collection while traversing the `indices` will defeat
the copy-on-write optimizations and cause the collection to make an unnecessary
copy.

Admittedly, the chances of this happening in our case are small, because most
random-access collections likely use plain integer indices where the `Indices`
type doesn't need to reference its base collection. For instance,
`Array.Indices` is `CountableRange<Int>` instead of the default
`DefaultRandomAccessIndices`. One example of a random-access collection that
uses a back-referencing `Indices` type is `String.UTF16View` (which, if you
recall from the strings chapter, conforms to `RandomAccessCollection` when you
import Foundation). But that one isn't a `MutableCollection` and therefore
doesn't meet the shuffling algorithm's requirements either.

Inside the loop, we measure the distance from the running index to the end and
then use our new `SignedInteger.arc4random` method to compute a random index to
swap with. The actual swap operation remains the same as in the non-generic
version.

You might wonder why we didn't extend `MutableCollection` when implementing the
non-modifying shuffle. Again, this is a pattern you see often in the standard
library — for example, when you `sort` a `ContiguousArray`, you get back an
`Array` and not a `ContiguousArray`.

In this case, the reason is that our immutable version relies on the ability to
clone the collection and then shuffle it in place. This, in turn, relies on the
collection having value semantics. But not all collections are guaranteed to
have value semantics. If `NSMutableArray` conformed to `MutableCollection`
(which it doesn't — probably because it's bad form for Swift collections to not
have value semantics — but could), then `shuffled` and `shuffle` would have the
same effect, since `NSMutableArray` has reference semantics. `var clone = self`
just makes a copy of the reference, so a subsequent `clone.shuffle` would
shuffle `self` — probably not what the user would expect. Instead, we take a
full copy of the elements into an array and shuffle and return that.

There's a compromise approach. You could write a version of `shuffle` to return
the same type of collection as the one being shuffled, so long as that type is
also a `RangeReplaceableCollection`:

*/

//#-editable-code
extension MutableCollection
    where Self: RandomAccessCollection,
        Self: RangeReplaceableCollection
{
    func shuffled() -> Self {
        var clone = Self()
        clone.append(contentsOf: self)
        clone.shuffle()
        return clone
    }
}
//#-end-editable-code

/*:
This relies on the two abilities of `RangeReplaceableCollection`: to create a
fresh empty version of the collection, and to then append any sequence (in this
case, `self`) to that empty collection, thus guaranteeing a full clone takes
place. The standard library doesn't take this approach — probably because the
consistency of always creating an array for any kind of non-in-place operation
is preferred — but it's an option if you want it. However, remember to create
the sequence version as well, so that you offer shuffling for non-mutable
range-replaceable collections and sequences.

*/
