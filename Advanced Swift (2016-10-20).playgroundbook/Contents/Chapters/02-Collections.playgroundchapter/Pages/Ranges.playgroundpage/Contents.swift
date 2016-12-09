/*:
## Ranges

A range is an interval of values, defined by its lower and upper bounds. You
create ranges with the two range operators: `..<` for half-open ranges that
don't include their upper bound, and `...` for closed ranges that include both
bounds:

*/

//#-editable-code
// 0 to 9, 10 is not included
let singleDigitNumbers = 0..<10

// "z" is included
let lowercaseLetters = Character("a")...Character("z")
//#-end-editable-code

/*:
Ranges seem like a natural fit to be sequences or collections, so it may
surprise you to learn that they're *neither* — at least not all of them are.

There are now four range types in the standard library. They can be classified
in a two-by-two matrix, as follows:

``` table
|                            | Half-open range  | Closed range           |
|:---------------------------|:-----------------|:-----------------------|
| Elements are `Comparable`  | `Range`          | `ClosedRange`          |
| Elements are `Strideable`  | `CountableRange` | `CountableClosedRange` |
| (with integer steps)       |                  |                        |
```

The columns of the matrix correspond to the two range operators we saw above,
which create a `[Countable]Range` (half-open) or a `[Countable]ClosedRange`
(closed), respectively. Half-open and closed ranges both have their place:

  - Only a **half-open range** can represent an **empty interval** (when the
    lower and upper bounds are equal, as in `5..<5`).

  - Only a **closed range** can contain the **maximum value** its element type
    can represent (e.g. `0...Int.max`). A half-open range always requires at
    least one representable value that's greater than the highest value in the
    range.

(In Swift 2, all ranges were technically half-open ranges, even if they were
created with the `...` operator; no range could contain the maximum expressible
value. The standard library used to have additional types, `HalfOpenInterval`
and `ClosedInterval`, to remedy this. They've been removed in Swift 3.)

The rows in the table distinguish between "normal" ranges whose element type
only conforms to the `Comparable` protocol (which is the minimum requirement),
and ranges over types that are `Strideable` *and* use integer steps between
elements. Only the latter ranges are collections, inheriting all the powerful
functionality we've seen in this chapter.

Swift calls these more capable ranges *countable* because only they can be
iterated over. Valid bounds for countable ranges include integer and pointer
types, but not floating-point types, because of the integer constraint on the
type's `Stride`. If you need to iterate over consecutive floating-point values,
you can use the `stride(from:to:by)` and `stride(from:through:by)` functions to
create such a sequence.

This means that you can iterate over some ranges but not over others. For
example, the range of `Character` values we defined above isn't a sequence, so
this won't work:

``` swift-example
for char in lowercaseLetters {
    // ...
}
// Error: Type 'ClosedRange<Character>' does not conform to protocol 'Sequence'
```

(The answer why iterating over characters isn't as straightforward as it would
seem has to do with Unicode, and we'll cover it at length in the chapter on
strings.)

Meanwhile, the following is no problem because an integer range is a countable
range and thus a collection:

*/

//#-editable-code
singleDigitNumbers.map { $0 * $0 }
//#-end-editable-code

/*:
The standard library currently has to have separate types for countable ranges,
`CountableRange` and `CountableClosedRange`. Ideally, these wouldn't be distinct
types, but rather extensions on `Range` and `ClosedRange` that add collection
conformance on the condition that the generic parameters meet the required
constraints. We'll talk a lot more about this in the next chapter, but the code
would look like this:

``` swift-example
// Invalid in Swift 3
extension Range: RandomAccessCollection
    where Bound: Strideable, Bound.Stride: SignedInteger
{
    // Implement RandomAccessCollection
}
```

Alas, Swift 3's type system can't express this idea, so separate types are
needed. Support for conditional conformance is expected for Swift 4, and
`CountableRange` and `CountableClosedRange` will be folded into `Range` and
`ClosedRange` when it lands.

The distinction between the half-open `Range` and the closed `ClosedRange` will
likely remain, and it can sometimes make working with ranges harder than it used
to be. Say you have a function that takes a `Range<Character>` and you want to
pass it the closed character range we created above. You may be surprised to
find out that it's not possible\! Inexplicably, there appears to be no way to
convert a `ClosedRange` into a `Range`. But why? Well, to turn a closed range
into an equivalent half-open range, you'd have to find the element that comes
after the original range's upper bound. And that's simply not possible unless
the element is `Strideable`, which is only guaranteed for countable ranges.

This means the caller of such a function will have to provide the correct type.
If the function expects a `Range`, you can't use the `...` operator to create
it. We're not certain how big of a limitation this is in practice, since most
ranges are likely integer based, but it's definitely unintuitive.

*/
