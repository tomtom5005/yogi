/*:
### Strings and Slicing

A good sign that a collection function will work well with strings is if the
result is a `SubSequence` of the input. Performing slicing operations on arrays
is a bit awkward, as the value you get back isn't an `Array`, but rather an
`ArraySlice`. This makes writing recursive functions that slice up their input
especially painful.

`String`'s collection views have no such trouble. They define their
`SubSequence` to be an instance of `Self`, so the generic functions that take a
sliceable type and return a subsequence work very well with strings. For
example, `world` here will be of type `String.CharacterView`:

*/

//#-editable-code
let world = "Hello, world!".characters.suffix(6).dropLast()
String(world)
//#-end-editable-code

/*:
`split`, which returns an array of subsequences, is also useful for string
processing. It's defined like so:

``` swift-example
extension Collection {
    func split(maxSplits: Int = default,
        omittingEmptySubsequences: Bool = default,
        whereSeparator isSeparator: (Self.Iterator.Element) throws -> Bool) 
        rethrows -> [AnySequence<Self.Iterator.Element>]
}
```

You can use its simplest form like this:

*/

//#-editable-code
let commaSeparatedArray = "a,b,c".characters.split { $0 == "," }
commaSeparatedArray.map(String.init)
//#-end-editable-code

/*:
This can serve a function similar to the `components(separatedBy:)` method
`String` inherits from `NSString`, but with added configurations for whether or
not to drop empty components. But since it takes a closure, it can do more than
just compare characters. Here's an example of a primitive word wrap, where the
closure captures a count of the length of the line thus far:

*/

//#-editable-code
extension String {
    func wrapped(after: Int = 70) -> String {
        var i = 0
        let lines = self.characters.split(omittingEmptySubsequences: false) { 
            character in
            switch character {
            case "\n", 
                 " " where i >= after:
                i = 0
                return true
            default:
                i += 1
                return false
            }
        }.map(String.init)
        return lines.joined(separator: "\n")
    }
}

let paragraph = "The quick brown fox jumped over the lazy dog."
paragraph.wrapped(after: 15)
//#-end-editable-code

/*:
The `map` on the end of the `split` is necessary because we want an array of
`String`, not an array of `String.CharacterView`.

That said, chances are that you'll want to split things by character most of the
time, so you might find it convenient to use the variant of `split` that takes a
single separator:

``` swift-example
extension Collection where Iterator.Element: Equatable {
    public func split(separator: Self.Iterator.Element,
        maxSplits: Int = default,
        omittingEmptySubsequences: Bool = default)
        -> [Self.SubSequence]
}
```

*/

//#-editable-code
"1,2,3".characters.split(separator: ",").map(String.init)
//#-end-editable-code

/*:
Or, consider writing a version that takes a sequence of multiple separators:

*/

//#-editable-code
extension Collection where Iterator.Element: Equatable {
    func split<S: Sequence>(separators: S) -> [SubSequence]
        where Iterator.Element == S.Iterator.Element
    {
        return split { separators.contains($0) }
    }
}
//#-end-editable-code

/*:
This way, you can write the following:

*/

//#-editable-code
"Hello, world!".characters.split(separators: ",! ".characters).map(String.init)
//#-end-editable-code
