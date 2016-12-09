/*:
### Subsequences

`Sequence` has another associated type, named `SubSequence`:

``` swift-example
protocol Sequence {
    associatedtype Iterator: IteratorProtocol
    associatedtype SubSequence
    // ...
}
```

`SubSequence` is used as the return type for operations that return slices of
the original sequence:

  - **`prefix`** and **`suffix`** — take the first or last *n* elements

  - **`dropFirst`** and **`dropLast`** — return subsequences where the first or
    last *n* elements have been removed

  - **`split`** — break up the sequence at the specified separator elements and
    return an array of subsequences

If you don't specify a type for `SubSequence`, the compiler will infer it to be
`AnySequence<Iterator.Element>` because `Sequence` provides default
implementations for the above methods with that return type. If you want to use
your own subsequence type, you must provide custom implementations for these
methods.

It can sometimes be convenient if `SubSequence == Self`, i.e. if subsequences
have the same type as the base sequence. A standard library type for which this
is the case is `String.CharacterView`. In the chapter on strings, we show some
examples where this feature makes working with character views more pleasant.

In an ideal world, the associated type declaration would include constraints to
ensure that `SubSequence` (a) is also a sequence, and (b) has the same element
and subsequence types as its base sequence. It should look something like this:

``` swift-example
// Invalid in Swift 3.0
associatedtype SubSequence: Sequence
    where Iterator.Element == SubSequence.Iterator.Element,
        SubSequence.SubSequence == SubSequence
```

This isn't possible in Swift 3.0 because the compiler lacks support for two
required features: recursive protocol constraints (`Sequence` would reference
itself) and `where` clauses on associated types. We expect both of these in a
future Swift release. Until then, you may find yourself having to add some or
all of these constraints to your own `Sequence` extensions to help the compiler
understand the types.

The following example checks if a sequence starts with the same *n* elements
from the head and the tail. It does this by comparing the sequence's prefix
element with the reversed suffix. The comparison using `elementsEqual` only
works if we tell the compiler that the subsequence is also a sequence, and that
its elements have the same type as the base sequence's elements (which we
constrained to `Equatable`):

*/

//#-editable-code
extension Sequence
    where Iterator.Element: Equatable,
        SubSequence: Sequence,
        SubSequence.Iterator.Element == Iterator.Element
{
    func headMirrorsTail(_ n: Int) -> Bool {
        let head = prefix(n)
        let tail = suffix(n).reversed()
        return head.elementsEqual(tail)
    }
}

[1,2,3,4,2,1].headMirrorsTail(2)
//#-end-editable-code


/*:
We show another example of this in the chapter on generics.

*/
