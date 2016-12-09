/*:
### `switch`-`case` Matching for Optionals:

Another consequence of optionals not being `Equatable` is that you can't check
them in a `case` statement. `case` matching is controlled in Swift by the `~=`
operator, and the relevant definition looks a lot like the one that wasn't
working for arrays:

``` swift-example
func ~=<T: Equatable>(a: T, b: T) -> Bool
```

But it's simple to produce a matching version for optionals that just calls
`==`:

*/

//#-editable-code
func ~=<T: Equatable>(pattern: T?, value: T?) -> Bool {
    return pattern == value
}
//#-end-editable-code

/*:
It's also nice to implement a range match at the same time:

*/

//#-editable-code
func ~=<Bound>(pattern: Range<Bound>, value: Bound?) -> Bool {
    return value.map { pattern.contains($0) } ?? false
}
//#-end-editable-code

/*:
Here, we use `map` to check if a non-`nil` value is inside the interval. Because
we want `nil` not to match any interval, we return `false` in case of `nil`.

Given this, we can now match optional values with `switch`:

*/

//#-editable-code
for i in ["2", "foo", "42", "100"] {
    switch Int(i) {
    case 42:
        print("The meaning of life")
    case 0..<10:
        print("A single digit")
    case nil:
        print("Not a number")
    default:
        print("A mystery number")
    }
}
//#-end-editable-code
