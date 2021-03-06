/*:
### Doubly Nested Optionals

This is a good time to point out that the type an optional wraps can itself be
optional, which leads to optionals nested inside optionals. To see why this
isn't just a strange edge case or something the compiler should automatically
coalesce, suppose you have an array of strings of numbers, which you want to
convert into integers. You might run them through a `map` to convert them:

*/

//#-editable-code
let stringNumbers = ["1", "2", "three"]
let maybeInts = stringNumbers.map { Int($0) }
//#-end-editable-code

/*:
You now have an array of `Optional<Int>` — i.e. `Int?` — because
`Int.init(String)` is failable, since the string might not contain a valid
integer. Here, the last entry will be a `nil`, since `"three"` isn't an integer.

When looping over the array with `for`, you'd rightly expect that each element
would be an optional integer, because that's what `maybeInts` contains:

*/

//#-editable-code
for maybeInt in maybeInts {
    // maybeInt is an Int?
    // Two numbers and a `nil`
}
//#-end-editable-code

/*:
Now consider that the implementation of `for...in` is shorthand for the `while`
loop technique above. What's returned from `next` would be an
`Optional<Optional<Int>>` — or `Int??` — because `next` wraps each element in
the sequence inside an optional. The `while let` unwraps it to check it isn't
`nil`, and while it's non-`nil`, binds the unwrapped value and runs the body:

*/

//#-editable-code
var iterator = maybeInts.makeIterator()
while let maybeInt = iterator.next() {
    print(maybeInt)
}
//#-end-editable-code

/*:
When the loop gets to the final element — the `nil` from `"three"` — what's
returned from `next` is a non-`nil` value: `.some(nil)`. It unwraps this and
binds what's inside (a `nil`) to `maybeInt`. Without doubly wrapped optionals,
this wouldn't be possible.

By the way, if you ever want to loop over only the non-`nil` values with `for`,
you can use `if case` pattern matching:

*/

//#-editable-code
for case let i? in maybeInts {
    // i will be an Int, not an Int?
    print(i, terminator: " ")
}

// Or only the nil values:
for case nil in maybeInts {
    // Will run once for each nil
    print("No value")
}
//#-end-editable-code

/*:
This uses a "pattern" of `x?`, which only matches non-`nil` values. This is
shorthand for `.some(x)`, so the loop could be written like this:

*/

//#-editable-code
for case let .some(i) in maybeInts {
    print(i)
}
//#-end-editable-code

/*:
This `case`-based pattern matching is a way to apply the same rules that work in
`switch` statements to `if`, `for`, and `while`. It's most useful with
optionals, but it also has other applications — for example:

*/

//#-editable-code
let j = 5
if case 0..<10 = j {
    print("\(j) within range")
}
//#-end-editable-code

/*:
Since case matching is extensible via implementations of the `~=` operator, this
means you can extend `if case` and `for case` in various interesting ways:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
struct Substring {
    let s: String
    init(_ s: String) { self.s = s }
}

func ~=(pattern: Substring, value: String) -> Bool {
    return value.range(of: pattern.s) != nil
}

let s = "Taylor Swift"
if case Substring("Swift") = s {
    print("has substring \"Swift\"")
}
//#-end-editable-code

/*:
This has incredible potential, but you need to be careful, as it's very easy to
accidentally write `~=` operators that match a little too much. On that note,
inserting the following into a common bit of library code would probably be a
good April Fools' joke:

``` swift-example
func ~=<T, U>(_: T, _: U) -> Bool { return true }
```

The code above will make every case match (unless a more specific version of
`~=` is already defined).

*/
