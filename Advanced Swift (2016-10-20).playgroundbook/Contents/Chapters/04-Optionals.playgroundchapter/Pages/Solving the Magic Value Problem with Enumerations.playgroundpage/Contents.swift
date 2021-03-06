/*:
## Solving the Magic Value Problem with Enumerations

Of course, every good programmer knows magic numbers are bad. Most languages
support some kind of enumeration type, which is a safer way of representing a
set of discrete possible values for a type.

Swift takes enumerations further with the concept of "associated values." These
are enumeration values that can also have another value associated with them:

``` swift-example
enum Optional<Wrapped> {
    case none
    case some(wrapped)
}
```

In some languages, these are called ["tagged
unions"](https://en.wikipedia.org/wiki/Tagged_union) (or "discriminated unions")
— a union being multiple different possible types all held in the same space in
memory, with a tag to tell which type is actually held. In Swift enums, this tag
is the enum case.

The only way to retrieve an associated value is via a `switch` or an `if case
let`. Unlike with a sentinel value, you can't accidentally use the value
embedded in an `Optional` without explicitly checking and unpacking it.

So instead of returning an index, the Swift equivalent of `find` — called
`index(of:)` — returns an `Optional<Index>` with a protocol extension
implementation somewhat similar to this:

*/

//#-editable-code
extension Collection where Iterator.Element: Equatable {
    func index_sample_impl(of element: Iterator.Element) -> Optional<Index> {
        var idx = startIndex
        while idx != endIndex {
            if self[idx] == element { 
                return .some(idx) 
            }
            formIndex(after: &idx)
        }
        // Not found, return .none
        return .none
    }
}
//#-end-editable-code

/*:
Since optionals are so fundamental in Swift, there's lots of syntax support to
neaten this up: `Optional<Index>` can be written `Index?`; optionals conform to
`ExpressibleByNilLiteral` so that you can write `nil` instead of `.none`; and
non-optional values (like `idx`) are automatically "upgraded" to optionals where
needed so that you can write `return idx` instead of `return .some(idx)`.

Now there's no way a user could mistakenly use the invalid value:

``` swift-example
var array = ["one", "two", "three"]
let idx = array.index(of: "four")
// Compile-time error: removeIndex takes an Int, not an Optional<Int>
array.remove(at: idx)
```

Instead, you're forced to "unwrap" the optional in order to get at the index
within, assuming you didn't get `none` back:

*/

//#-editable-code
var array = ["one","two","three"]
switch array.index(of: "four") {
case .some(let idx):
    array.remove(at: idx)
case .none:
    break  // do nothing
}
//#-end-editable-code

/*:
This switch statement writes the enumeration syntax for optionals out longhand,
including unpacking the "associated type" when the value is the `some` case.
This is great for safety, but it's not very pleasant to read or write. Swift 2.0
introduced the `?` pattern suffix syntax to match a `some` optional inside a
switch, and you can use the `nil` literal to match `none`:

*/

//#-editable-code
switch array.index(of: "four") {
case let idx?:
    array.remove(at: idx)
case nil:
    break // Do nothing
}
//#-end-editable-code

/*:
But this is still clunky. Let's take a look at all the other ways you can make
your optional processing short and clear, depending on your use case.

*/
