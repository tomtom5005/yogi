/*:
There's another way in which `isSubset` can be made more general. Up until now,
it's only taken an array of elements to check against. But `Array` is a specific
type. Really, `isSubset` doesn't need to be this specific. Across the two
versions, there are only two function calls: `contains` in both, and `Set.init`
in the `Hashable` version. In both cases, these functions only require an input
type that conforms to the `Sequence` protocol:

``` swift-example
extension Sequence where Iterator.Element: Equatable {
    /// Returns a Boolean value indicating whether the sequence contains the
    /// given element.
    func contains(_ element: Iterator.Element) -> Bool
}

struct Set<Element: Hashable>:
    SetAlgebra, Hashable, Collection, ExpressibleByArrayLiteral
{
    /// Creates a new set from a finite sequence of items.
    init<Source: Sequence>(_ sequence: Source)
        where Source.Iterator.Element == Element
}
```

Given this, the only thing `isSubset` needs is for `other` to be of some type
that also conforms to `Sequence`. What's more is that the two sequence types —
`self` and `other` — *don't have to be the same*. They just need to be sequences
of the same element. So here's the `Hashable` version, rewritten to operate on
any two kinds of sequence:

*/

//#-editable-code
extension Sequence where Iterator.Element: Hashable {
    /// Returns true iff all elements in `self` are also in `other`.
    func isSubset<S: Sequence>(of other: S) -> Bool
        where S.Iterator.Element == Iterator.Element
    {
        let otherSet = Set(other)
        for element in self {
            guard otherSet.contains(element) else {
                return false
            }
        }
        return true
    }
}
//#-end-editable-code

/*:
Now that the two sequences don't have to be the same type, this opens up a lot
more possibilities. For example, you could pass in a `CountableRange` of numbers
to check against:

*/

//#-editable-code
[5,4,3].isSubset(of: 1...10)
//#-end-editable-code

/*:
A similar change can be made to the version that requires the elements to be
equatable (not shown here).

*/

//#-hidden-code
extension Sequence where Iterator.Element: Equatable {
    func isSubset<S: Sequence>(of other: S) -> Bool
        where S.Iterator.Element == Iterator.Element
    {
        for element in self {
            guard other.contains(element) else {
                return false
            }
        }
        return true
    }
}
//#-end-hidden-code

