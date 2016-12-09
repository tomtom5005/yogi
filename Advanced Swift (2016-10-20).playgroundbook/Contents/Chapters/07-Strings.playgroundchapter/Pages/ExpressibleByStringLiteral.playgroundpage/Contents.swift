/*:
## `ExpressibleByStringLiteral`

Throughout this chapter, we've been using `String("blah")` and `"blah"` pretty
much interchangeably, but they're different. `""` is a string literal, just like
the array literals covered in the collection protocols chapter. You can make
your types initializable from a string literal by conforming to
`ExpressibleByStringLiteral`.

String literals are slightly more work to implement than array literals because
they're part of a hierarchy of three protocols: `ExpressibleByStringLiteral`,
`ExpressibleByExtendedGraphemeClusterLiteral`, and
`ExpressibleByUnicodeScalarLiteral`. Each defines an `init` for creating a type
from each kind of literal, so you have to implement all three. But unless you
really need fine-grained logic based on whether or not the value is being
created from a single scalar/cluster, it's probably easiest to implement them
all in terms of the string version, like so:

*/

//#-hidden-code
/// A simple regular expression type, supporting ^ and $ anchors,
/// and matching with . and *
public struct Regex {
    fileprivate let regexp: String
    
    /// Construct from a regular expression String
    public init(_ regexp: String) {
        self.regexp = regexp
    }
}
//#-end-hidden-code

//#-hidden-code
extension Regex {
    /// Returns true if the string argument matches the expression.
    public func match(_ text: String) -> Bool {

        // If the regex starts with ^, then it can only match the
        // start of the input
        if regexp.characters.first == "^" {
            return Regex.matchHere(regexp: regexp.characters.dropFirst(),
                text: text.characters)
        }

        // Otherwise, search for a match at every point in the input
        // until one is found
        var idx = text.startIndex
        while true {
            if Regex.matchHere(regexp: regexp.characters,
                text: text.characters.suffix(from: idx))
            {
                return true
            }
            guard idx != text.endIndex else { break }
            text.characters.formIndex(after: &idx)
        }

        return false
    }
}
//#-end-hidden-code

//#-hidden-code
extension Regex {
    /// Match a regular expression string at the beginning of text.
    fileprivate static func matchHere(
        regexp: String.CharacterView, text: String.CharacterView) -> Bool
    {
        // Empty regexprs match everything
        if regexp.isEmpty {
            return true
        }

        // Any character followed by * requires a call to matchStar
        if let c = regexp.first, regexp.dropFirst().first == "*" {
            return matchStar(character: c, regexp: regexp.dropFirst(2), text: text)
        }

        // If this is the last regex character and it's $, then it's a match iff the
        // remaining text is also empty
        if regexp.first == "$" && regexp.dropFirst().isEmpty {
            return text.isEmpty
        }

        // If one character matches, drop one from the input and the regex
        // and keep matching
        if let tc = text.first, let rc = regexp.first, rc == "." || tc == rc {
            return matchHere(regexp: regexp.dropFirst(), text: text.dropFirst())
        }

        // If none of the above, no match
        return false
    }

    /// Search for zero or more `c`'s at beginning of text, followed by the
    /// remainder of the regular expression.
    fileprivate static func matchStar
        (character c: Character, regexp: String.CharacterView,
            text: String.CharacterView)
        -> Bool
    {
        var idx = text.startIndex
        while true {   // a * matches zero or more instances
            if matchHere(regexp: regexp, text: text.suffix(from: idx)) {
                return true
            }
            if idx == text.endIndex || (text[idx] != c && c != ".") {
                return false
            }
            text.formIndex(after: &idx)
        }
    }
}
//#-end-hidden-code

//#-editable-code
extension Regex: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        regexp = value
    }
    public init(extendedGraphemeClusterLiteral value: String) {
        self = Regex(stringLiteral: value)
    }
    public init(unicodeScalarLiteral value: String) {
        self = Regex(stringLiteral: value)
    }
}
//#-end-editable-code

/*:
Once defined, you can begin using string literals to create the regex matcher by
explicitly naming the type:

*/

//#-editable-code
let r: Regex = "^h..lo*!$"
//#-end-editable-code

/*:
Or even better is when the type is already named for you, because the compiler
can then infer it:

*/

//#-editable-code
func findMatches(in strings: [String], regex: Regex) -> [String] {
    return strings.filter { regex.match($0) }
}
findMatches(in: ["foo","bar","baz"], regex: "^b..")
//#-end-editable-code

/*:
By default, string literals create the `String` type because of this `typealias`
in the standard library:

``` swift-example
typealias StringLiteralType = String
```

But if you wanted to change this default specifically for your application
(perhaps because you had a different kind of string that was faster for your
particular use case — say it implemented a small-string optimization where a
couple of characters were held directly in the string itself), you could change
this by re-aliasing the value:

``` swift-example
typealias StringLiteralType = StaticString

let what = "hello"
what is StaticString // true
```

*/
