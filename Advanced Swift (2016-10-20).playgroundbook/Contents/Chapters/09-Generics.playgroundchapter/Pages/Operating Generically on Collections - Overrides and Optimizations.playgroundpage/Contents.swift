/*:
### Overrides and Optimizations

Finally, it's often the case that you can provide a more efficient generic
algorithm if you tighten the constraints slightly. For example, you could
improve the speed of the `search` algorithm above if you knew that both the
searched collection and the pattern were random-access collections. That way,
you could avoid searching for the pattern in the part of the collection that was
too short to match it, and when the pattern was longer than the collection, you
could avoid searching completely.

For this to work, you need to guarantee that both `Self` and `Other` conform to
`RandomAccessCollection`. We then find ourselves with an algorithm that's about
as much constraint as it is code:

*/

//#-editable-code
extension RandomAccessCollection
    where Iterator.Element: Equatable,
        Indices.Iterator.Element == Index,
        SubSequence.Iterator.Element == Iterator.Element,
        SubSequence.Indices.Iterator.Element == Index
{
    func search<Other: RandomAccessCollection>
        (for pattern: Other) -> Index?
        where Other.IndexDistance == IndexDistance,
            Other.Iterator.Element == Iterator.Element
    {
        // If pattern is longer, this cannot match, exit early.
        guard !isEmpty && pattern.count <= count else { return nil }

        // Otherwise, from the start up to the end
        // less space for the pattern …
        let stopSearchIndex = index(endIndex, offsetBy: -pattern.count)

        // … check if a slice from this point
        // starts with the pattern.
        return prefix(upTo: stopSearchIndex).indices.first { idx in
            suffix(from: idx).starts(with: pattern)
        }
    }
}

let numbers = 1..<100
numbers.search(for: 80..<90)
//#-end-editable-code


/*:
We've added one other constraint here: the distance types of the two collections
are the same. This keeps the code simple, though it does rule out the
possibility that they might differ. This is pretty rare though — the
type-erasing `AnyCollection` struct uses `IntMax`, which is different from `Int`
on 32-bit systems. The alternative would be a light sprinkling of `numericCast`s
— for example, `guard numericCast(pattern.count) <= count else { return nil }`.
We also had to add `SubSequence.Indices.Iterator.Element == Index` to make sure
that the element type of `prefix(upTo: stopSearchIndex).indices` is the
collection's index type. Again, this should be trivially true, but we need to
explicitly tell it to the compiler.

*/
