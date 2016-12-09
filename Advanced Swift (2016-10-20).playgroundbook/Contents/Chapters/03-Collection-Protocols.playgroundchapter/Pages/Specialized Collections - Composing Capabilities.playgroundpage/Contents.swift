/*:
#### Composing Capabilities

The specialized collection protocols can be composed very elegantly into a set
of constraints that exactly matches the requirements of each specific operation.
As an example, take the `sort` method in the standard library for sorting a
collection in place (unlike its non-mutating sibling, `sorted`, which returns
the sorted elements in an array). Sorting in place requires the collection to be
mutable. If you want the sort to be fast, you also need random access. Last but
not least, you need to be able to compare the collection's elements to each
other.

Combining these requirements, the `sort` method is defined in an extension to
`MutableCollection`, with `RandomAccessCollection` and `Element: Comparable` as
additional constraints:

``` swift-example
extension MutableCollection
    where Self: RandomAccessCollection, Iterator.Element: Comparable {
    /// Sorts the collection in place.
    public mutating func sort() { ... }
}
```

*/
