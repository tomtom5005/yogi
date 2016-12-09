/*:
### `SubSequence` and Generic Algorithms

Here's one final example to demonstrate a problem you'll encounter if you try
and use slicing generically.

Say you want to write an algorithm that searches for a given subsequence — so
similar to `index(of:)`, but searching for a subsequence rather than an
individual element. In theory, a naive solution to this is simple: return the
first index where the slice from that index to the end of the collection starts
with the pattern. We can use `index(where:)` for this. However, if you try it,
you'll find you get a compiler error:

``` swift-example
extension Collection where Iterator.Element: Equatable {
    func search<Other: Sequence>(for pattern: Other) -> Index?
        where Other.Iterator.Element == Iterator.Element
    {
        return indices.first { idx in
            // Error: Missing argument for parameter 'by'
            suffix(from: idx).starts(with: pattern)
        }
    }
}
```

The error message suggests that the compiler expects `starts(with:by:)` here,
which takes an additional closure to determine if two elements are equivalent.
This seems odd. The non-parameterized variant, `starts(with:)`, should be
available to sequences whose elements are `Equatable`, which is exactly what we
specified for our extension (via `Iterator.Element: Equatable`).

We also constrained the elements of `Other` to be the same as our own elements
(via `Other.Iterator.Element == Iterator.Element`), as is required by both
`starts(with:)` overloads. Unfortunately, though, there's one thing that isn't
guaranteed, which is that `SubSequence.Iterator.Element` — that is, the type of
an element in a slice — is equal to the type of an element in the collection. Of
course it should be\! But as of Swift 3.0, the language isn't powerful enough to
write this constraint. This makes the slice we create with `suffix(from: idx)`
incompatible with `Other` in the eyes of the compiler.

Fixing this on the language level would require a redeclaration of the
`SubSequence` associated type with the constraint that
`SubSequence.Iterator.Element` must be equal to `Iterator.Element`, but `where`
clauses on associated types are currently not supported. However, Swift will
likely get this feature in the future.

Until then, you must constrain your protocol extension to ensure that any slices
you use contain the same element as the collection. A first attempt might be to
require the subsequence be the same as the collection:

``` swift-example
extension Collection
    where Iterator.Element: Equatable, SubSequence == Self {
    // Implementation of search same as before
}
```

This would work when a subsequence has the same type as its collection, like in
the case with strings. But as we saw in the built-in collections chapter, the
slice type for arrays is `ArraySlice`, so you still couldn't `search` arrays.
Therefore, we need to loosen the constraint a little and instead require that
the subsequences' elements match:

``` swift-example
extension Collection
    where Iterator.Element: Equatable,
        SubSequence.Iterator.Element == Iterator.Element
{
    // Implementation of search same as before
}
```

The compiler responds to this with another error message, this time regarding
the trailing closure argument of the `indices.first` call: "Cannot convert value
of type `(Self.Index) -> Bool` to expected argument type `(_) -> Bool`." What
does this mean? It's essentially the same problem, but this time, it's for
indices instead of elements. The type system can't express the idea that the
element type of `Indices` (which itself is a collection) is always equal to the
collection's index type — therefore, the `idx` parameter of the closure (which
has the type `Indices.Iterator.Element`) is incompatible with the argument type
`suffix(from:)` expects (which is `Index`).

Adding this constraint to the extension finally makes the code compile:

*/

//#-editable-code
extension Collection
    where Iterator.Element: Equatable,
        SubSequence.Iterator.Element == Iterator.Element,
        Indices.Iterator.Element == Index
{
    func search<Other: Sequence>(for pattern: Other) -> Index?
        where Other.Iterator.Element == Iterator.Element
    {
        return indices.first { idx in
            suffix(from: idx).starts(with: pattern)
        }
    }
}

let text = "It was the best of times, it was the worst of times"
text.characters.search(for: ["b","e","s","t"])
//#-end-editable-code


/*:
Notice that throughout this entire process we haven't changed the actual code
once, only the constraints that specify the requirements types must meet to use
this functionality.

*/
