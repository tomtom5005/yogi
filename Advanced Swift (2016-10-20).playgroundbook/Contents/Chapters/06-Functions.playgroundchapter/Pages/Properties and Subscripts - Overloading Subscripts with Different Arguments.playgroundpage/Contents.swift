/*:
### Overloading Subscripts with Different Arguments

We've already seen subscripts in Swift. For example, we can perform a dictionary
lookup like so: `dictionary[key]`. These subscripts are very much a hybrid
between functions and computed properties, with their own special syntax. Like
functions, they take arguments. Like computed properties, they can be either
read-only (using `get`) or read-write (using `get set`). Just like normal
functions, we can overload them by providing multiple variants with different
types — something that isn't possible with properties. For example, arrays have
two subscripts by default — one to access a single element, and one to get at a
slice:

*/

//#-editable-code
let fibs = [0, 1, 1, 2, 3, 5]
let first = fibs[0]
fibs[1..<3]
//#-end-editable-code

/*:
We can add subscripting support to our own types, and we can also extend
existing types with new subscript overloads. As an example, let's define a
`Collection` subscript that takes a *half-bounded* interval, i.e. a range where
there's only one end specified (either the `lowerBound` or the `upperBound`).

In Swift, the `Range` type represents bounded intervals: every `Range` has a
lower bound and an upper bound. As we demonstrated above, we can use this to
find a subsequence of an array (or to be more precise: of any `Collection`).
We'll extend `Collection` to support half-bounded intervals using a similar
operator. Using `suffix(from:)` and `prefix(upTo:)`, we can already access these
subsequences.

To represent half-bounded intervals, we'll create two new `struct`s:

*/

//#-editable-code
struct RangeStart<I> { let start: I }
struct RangeEnd<I> { let end: I }
//#-end-editable-code

/*:
We can define two convenience operators to write these intervals. These are
`prefix` and `postfix` operators, and they only have one operand. This will
allow us to write `RangeStart(x)` as `x..<` and `RangeEnd(x)` as `..<x`:

*/

//#-editable-code
postfix operator ..<
postfix func ..<<I>(lhs: I) -> RangeStart<I> {
    return RangeStart(start: lhs)
}

prefix operator ..<
prefix func ..<<I>(rhs: I) -> RangeEnd<I> {
    return RangeEnd(end: rhs)
}
//#-end-editable-code

/*:
Finally, we can extend `Collection` to support half-bounded ranges by adding two
new subscripts:

*/

//#-editable-code
extension Collection {
    subscript(r: RangeStart<Index>) -> SubSequence {
        return suffix(from: r.start)
    }
    subscript(r: RangeEnd<Index>) -> SubSequence {
        return prefix(upTo: r.end)
    }
}
//#-end-editable-code

/*:
This allows us to write half-bounded subscripts like so:

*/

//#-editable-code
fibs[2..<]
//#-end-editable-code

/*:
Using the `suffix(from:)` and `prefix(upTo:)` methods directly would save a lot
of effort, and adding a custom operator for this is probably overkill. However,
it's a nice example of `prefix` and `postfix` operators and custom subscripts.

### Advanced Subscripts

Now that we've seen how to add simple subscripts, we can take things a bit
further. Instead of taking a single parameter, subscripts can also take more
than one parameter (just like functions). The following extension allows for
dictionary lookup (and updating) with a default value. During a lookup, when the
key isn't present, we return the default value (instead of `nil`, as the default
dictionary subscript would). In the setter, we ignore it (because `newValue`
isn't optional):

*/

//#-editable-code
extension Dictionary {
    subscript(key: Key, or defaultValue: Value) -> Value {
        get {
            return self[key] ?? defaultValue
        }
        set(newValue) {
            self[key] = newValue
        }
    }
}
//#-end-editable-code

/*:
This allows us to write a very short computed property for the frequencies in a
sequence. We start with an empty dictionary, and for every element we encounter,
we increment the frequency. If the element wasn't present in the dictionary
before, the default value of `0` is returned during lookup:

*/

//#-editable-code
extension Sequence where Iterator.Element: Hashable {
    var frequencies: [Iterator.Element: Int] {
        var result: [Iterator.Element: Int] = [:]
        for x in self {
            result[x, or: 0] += 1
        }
        return result
    }
}

"hello".characters.frequencies
//#-end-editable-code
