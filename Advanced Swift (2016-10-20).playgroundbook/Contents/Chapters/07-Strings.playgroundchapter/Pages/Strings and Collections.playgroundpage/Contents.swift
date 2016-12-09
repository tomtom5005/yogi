/*:
## Strings and Collections

Strings in Swift have an `Index` associated type, `startIndex` and `endIndex`
properties, a `subscript` that takes the index to fetch a specific character,
and an `index(after:)` method that advances an index by one.

This means that `String` meets all the criteria needed to qualify as conforming
to `Collection`. Yet `String` is *not* a collection. You can't use it with
`for...in`, nor does it inherit all the protocol extensions of `Collection` or
`Sequence`.

In theory, you can change this yourself by extending `String`:

``` swift-example
extension String: Collection {
    // Nothing needed here – it already has the necessary implementations
}

var greeting = "Hello, world!"
greeting.dropFirst(7) // "world!"
```

However, this is probably not wise. Strings aren't collections for a reason —
this isn't just because the Swift team forgot. When Swift 2.0 introduced
protocol extensions, this had the huge benefit of granting all collections and
sequences method-like access to dozens of useful algorithms. But this also led
to some concerns that collection-processing algorithms presenting themselves as
methods on strings would give the implicit indication that such methods are
completely safe and Unicode-correct, which wouldn't necessarily be true. Even
though `Character` does its best to present combining character sequences as
single values, as seen above, there are still some cases where processing a
string character by character can result in incorrect results.

To this end, the collection-of-characters view of strings was moved to a
property, `characters`, which put it on a footing similar to the other
collection views: `unicodeScalars`, `utf8`, and `utf16`. Picking a specific view
prompts you to acknowledge that you're moving into a "collection-processing"
mode and that you should consider the consequences of the algorithm you're about
to run.

`CharacterView`, however, has a special place among those views. `String.Index`
is actually just a type alias for `CharacterView.Index`. This means that once
you've found an index into the character view, you can then index directly into
the string with it.

But for reasons that should be clear from the examples in the previous section,
the characters view isn't a random-access collection. How could it be, when
knowing where the *n*^th^ character of a particular string is involves
evaluating just how many code points precede that character?

For this reason, `CharacterView` conforms only to `BidirectionalCollection`. You
can start at either end of the string, moving forward or backward, and the code
will look at the composition of the adjacent characters and skip over the
correct number of bytes. However, you need to iterate up and down one character
at a time.

Like all collection indices, string indices conform to `Comparable`. You might
not know how many characters lie between two indices, but you do at least know
that one lies before the other.

You can automate iterating over multiple characters in one go via the
`index(_:offsetBy:)` method:

*/

//#-editable-code
let s = "abcdef"
// Advance 5 from the start
let idx = s.index(s.startIndex, offsetBy: 5)
s[idx]
//#-end-editable-code

/*:
If there's a risk of advancing past the end of the string, you can add a
`limitedBy:` parameter. The method returns `nil` if it hits the limit before
reaching the target index:

*/

//#-editable-code
let safeIdx = s.index(s.startIndex, offsetBy: 400, limitedBy: s.endIndex)
safeIdx
//#-end-editable-code

/*:
This behavior is new in Swift 3.0. The corresponding method in Swift 2.2,
`advancedBy(_:limit:)`, didn't differentiate between hitting the limit and going
beyond it — it returned the end value in both situations. By returning an
optional, the new API is more expressive.

Now, you might look at this and think, "I know\! I can use this to give strings
integer subscripting\!" So you might do something like this:

``` swift-example
extension String {
    subscript(idx: Int) -> Character {
        guard let strIdx = index(startIndex, offsetBy: idx, limitedBy: endIndex)
            else { fatalError("String index out of bounds") }
        return self[strIdx]
    }
}
s[5]  // returns "f"
```

However, just as is the case with extending `String` to make it a collection,
this kind of extension is best avoided. You might otherwise be tempted to start
writing code like this:

``` swift-example
for i in 0..<5 {
    print(s[i])
}
```

As simple as this code looks, it's horribly inefficient. Every time `s` is
accessed with an integer, an `O(n)` function to advance its starting index is
run. Running a linear loop inside another linear loop means this `for` loop is
accidentally `O(n^2)` — as the length of the string increases, the time this
loop takes increases quadratically.

To someone used to dealing with fixed-width characters, this seems challenging
at first — how will you navigate without integer indices? And indeed, some
seemingly simple tasks like extracting the first four characters of a string can
turn into monstrosities like this one:

*/

//#-editable-code
s[s.startIndex..<s.index(s.startIndex, offsetBy: 4)]
//#-end-editable-code

/*:
But thankfully, `String` providing access to characters via a collection also
means you have several helpful techniques at your disposal. Many of the methods
that operate on `Array` also work on `String.characters`. Using the `prefix`
method, the same thing looks much clearer (note that this returns a
`CharacterView`; to convert it back into a `String`, we need to wrap it in a
`String.init`):

*/

//#-editable-code
String(s.characters.prefix(4))
//#-end-editable-code

/*:
Iterating over characters in a string is easy without integer indices; just use
a `for` loop. If you want to number each character in turn, use `enumerated()`:

*/

//#-editable-code
for (i, c) in "hello".characters.enumerated() {
    print("\(i): \(c)")
}
//#-end-editable-code

/*:
Or say you want to find a specific character. In that case, you can use
`index(of:)`:

*/

//#-editable-code
var hello = "Hello!"
if let idx = hello.characters.index(of: "!") {
    hello.insert(contentsOf: ", world".characters, at: idx)
}
hello
//#-end-editable-code

/*:
Note here that while the index was found using `characters.index(of:)`, the
`insert(contentsOf:)` method is called directly on the string, because
`String.Index` is just an alias for `Character.Index`. The `insert(contentsOf:)`
method inserts another collection of the same element type (e.g. `Character` for
strings) after a given index. This doesn't have to be another `String`; you
could insert an array of characters into a string just as easily.

Just like `Array`, `String` meets all the criteria to conform to
`RangeReplaceableCollection` — but again, it doesn't conform to it. You could
add the conformance manually, but we once more advise against it because it
falsely implies that all collection operations are Unicode-safe in every
situation:

``` swift-example
extension String: RangeReplaceableCollection { }

if let comma = greeting.index(of: ",") {
    print(greeting[greeting.startIndex..<comma])
    greeting.replaceSubrange(greeting.startIndex..<greeting.endIndex,
        with: "How about some original example strings?")
}
```

One collection-like feature strings do *not* provide is that of
`MutableCollection`. This protocol adds one feature to a collection — that of
the single-element subscript `set` — in addition to `get`. This isn't to say
strings aren't mutable — they have several mutating methods. But what you can't
do is replace a single character using the subscript operator. The reason comes
back to variable-length characters. Most people can probably intuit that a
single-element subscript update would happen in constant time, as it does for
`Array`. But since a character in a string may be of variable width, updating a
single character could take linear time in proportion to the length of the
string, because changing the width of a single element might require shuffling
all the later elements up or down in memory. Moreover, indices that come after
the replaced index would become invalid through the shuffling, which is equally
unintuitive. For these reasons, you have to use `replaceSubrange`, even if the
range you pass in is only a single element.

*/

