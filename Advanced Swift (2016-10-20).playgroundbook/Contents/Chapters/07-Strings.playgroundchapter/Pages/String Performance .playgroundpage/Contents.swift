/*:
## String Performance 

There's no denying that coalescing multiple variable-length UTF-16 values into
extended grapheme clusters is going to be more expensive than just ripping
through a buffer of 16-bit values. But what's the cost? One way to test
performance would be to adapt the regular expression matcher above to work
against all of the different collection views.

However, this presents a problem. Ideally, you'd write a generic regex matcher
with a placeholder for the view. But this doesn't work — the four different
views don't all implement a common "string view" protocol. Also, in our regex
matcher, we need to represent specific character constants like `*` and `^` to
compare against the regex. In the `UTF16View`, these would need to be `UInt16`,
but with the character view, they'd need to be characters. Finally, we want the
regex matcher initializer itself to still take a `String`. How would it know
which method to call to get the appropriate view out?

One technique is to bundle up all the variable logic into a single type and then
parameterize the regex matcher on that type. First, we define a protocol that
has all the necessary information:

*/

//#-editable-code
protocol StringViewSelector {
    associatedtype View: Collection
    
    static var caret: View.Iterator.Element { get }
    static var asterisk: View.Iterator.Element { get }
    static var period: View.Iterator.Element { get }
    static var dollar: View.Iterator.Element { get }
    
    static func view(from s: String) -> View
}
//#-end-editable-code

/*:
This information includes an associated type for the view we're going to use,
getters for the four constants needed, and a function to extract the relevant
view from a string.

Given this, you can implement concrete versions like so:

*/

//#-editable-code
struct UTF8ViewSelector: StringViewSelector {
    static var caret: UInt8 { return UInt8(ascii: "^") }
    static var asterisk: UInt8 { return UInt8(ascii: "*") }
    static var period: UInt8 { return UInt8(ascii: ".") }
    static var dollar: UInt8 { return UInt8(ascii: "$") }
    
    static func view(from s: String) -> String.UTF8View { return s.utf8 }
}

struct CharacterViewSelector: StringViewSelector {
    static var caret: Character { return "^" }
    static var asterisk: Character { return "*" }
    static var period: Character { return "." }
    static var dollar: Character { return "$" }
    
    static func view(from s: String) -> String.CharacterView { return s.characters }
}
//#-end-editable-code

/*:
You can probably guess what `UTF16ViewSelector` and `UnicodeScalarViewSelector`
look like.

*/

//#-hidden-code
struct UTF16ViewSelector: StringViewSelector {
    static var caret: UInt16 { return "^".utf16.first! }
    static var asterisk: UInt16 { return "*".utf16.first! }
    static var period: UInt16 { return ".".utf16.first! }
    static var dollar: UInt16 { return "$".utf16.first! }
    
    static func view(from s: String) -> String.UTF16View { return s.utf16 }
}

struct UnicodeScalarViewSelector: StringViewSelector {
    static var caret: UnicodeScalar { return UnicodeScalar("^") }
    static var asterisk: UnicodeScalar { return UnicodeScalar("*") }
    static var period: UnicodeScalar { return UnicodeScalar(".") }
    static var dollar: UnicodeScalar { return UnicodeScalar("$") }
    
    static func view(from s: String) -> String.UnicodeScalarView { return s.unicodeScalars }
}
//#-end-hidden-code

/*:
These are what some people call "phantom types" — types that only exist at
compile time and that don't actually hold any data. Try calling
`MemoryLayout<CharacterViewSelector>.size` — it'll return zero. It contains no
data. All we're using these types for is to parameterize behavior of another
type: the regex matcher. It'll use them like so:

``` swift-example
struct Regex<V: StringViewSelector>
    where V.View.Iterator.Element: Equatable,
    V.View.SubSequence == V.View
{
    let regexp: String
    /// Construct from a regular expression String.
    init(_ regexp: String) {
        self.regexp = regexp
    }
}

extension Regex {
    /// Returns true if the string argument matches the expression.
    func match(text: String) -> Bool {
        let text = V.view(from: text)
        let regexp = V.view(from: self.regexp)

        // If the regex starts with ^, then it can only match the start
        // of the input.
        if regexp.first == V.caret {
            return Regex.matchHere(regexp: regexp.dropFirst(), text: text)
        }

        // Otherwise, search for a match at every point in the input until
        // one is found.
        var idx = text.startIndex
        while true {
            if Regex.matchHere(regexp: regexp, text: text.suffix(from: idx)) {
                return true
            }
            guard idx != text.endIndex else { break }
            text.formIndex(after: &idx)
        }
        return false
    }

    /// Match a regular expression string at the beginning of text.
    fileprivate static func matchHere(regexp: V.View, text: V.View) -> Bool {
        // ...
    }    
    // ...
}
```

Once the code is rewritten like this, it's easy to write some benchmarking code
that measures the time taken to process some arbitrary regular expression across
very large input:

``` swift-example
func benchmark<V: StringViewSelector>(_: V.Type)
    where V.View.Iterator.Element: Equatable, V.View.SubSequence == V.View
{
    let r = Regex<V>("h..a*")
    var count = 0
    
    let startTime = CFAbsoluteTimeGetCurrent()
    while let line = readLine() {
        if r.match(text: line) { count = count &+ 1 }
    }
    let totalTime = CFAbsoluteTimeGetCurrent() - startTime
    print("\(V.self): \(totalTime) s")
}

func ~=<T: Equatable>(lhs: T, rhs: T?) -> Bool {
    return lhs == rhs
}

switch CommandLine.arguments.last {
case "ch": benchmark(CharacterViewSelector.self)
case "8": benchmark(UTF8ViewSelector.self)
case "16": benchmark(UTF16ViewSelector.self)
case "sc": benchmark(UnicodeScalarViewSelector.self)
default: print("unrecognized view type")
}
```

The results show the following speeds for the different views in processing the
regex on a large corpus of English text (128,000 lines, 1 million words):

``` table
View             Time
---------------  ------------
UTF16            0.3 seconds
UnicodeScalars   0.3 seconds
UTF8             0.4 seconds
Characters       4.2 seconds
```

Only you can know if your use case justifies choosing your view type based on
performance. It's almost certainly the case that these performance
characteristics only matter when you're doing extremely heavy string
manipulation, but if you're certain that what you're doing would be correct when
operating on UTF-16, Unicode scalar, or UTF-8 data, this can give you a decent
speedup.

*/
