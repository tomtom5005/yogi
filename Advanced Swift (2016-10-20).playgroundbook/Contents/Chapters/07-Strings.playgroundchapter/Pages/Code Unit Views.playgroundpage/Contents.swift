/*:
## Code Unit Views

Sometimes it's necessary to drop down to a lower level of abstraction and
operate directly on Unicode code units instead of characters. There are a few
common reasons for this.

Firstly, maybe you actually need the code units, perhaps for rendering into a
UTF-8-encoded webpage, or for interoperating with a non-Swift API that takes
them.

For an example of an API that requires code units, let's look at using
`CharacterSet` from the Foundation framework in combination with Swift strings.
The `CharacterSet` API is mostly defined in terms of Unicode scalars. So if you
wanted to use `CharacterSet` to split up a string, you could do it via the
`unicodeScalars` view:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
extension String {
    func words(with charset: CharacterSet = .alphanumerics) -> [String] {
        return self.unicodeScalars.split {
            !charset.contains($0)
        }.map(String.init)
    }
}

let s = "Wow! This contains _all_ kinds of things like 123 and \"quotes\"?"
s.words()
//#-end-editable-code

/*:
This will break the string apart at every non-alphanumeric character, giving you
an array of `String.UnicodeScalarView` slices. They can be turned back into
strings via `map` with the `String` initializer that takes a
`UnicodeScalarView`.

The good news is, even after going through this fairly extensive pipeline, the
string slices in `words` will *still* just be views onto the original string;
this property isn't lost by going via the `UnicodeScalarView` and back again.

A second reason for using these views is that operating on code units rather
than fully composed characters can be much faster. This is because to compose
grapheme clusters, you must look ahead of every character to see if it's
followed by combining characters. To see just how much faster these views can
be, take a look at the performance section later on.

Finally, the UTF-16 view has one benefit the other views don't have: it can be
random access. This is possible for just this view type because, as we've seen,
this is how strings are held internally within the `String` type. What this
means is the *n*^th^ UTF-16 code unit is always at the *n*^th^ position in the
buffer (even if the string is in "ASCII buffer mode" – it's just a question of
the width of the entries to advance over).

The Swift team made the decision *not* to conform `String.UTF16View` to
`RandomAccessCollection` in the standard library, though. Instead, they moved
the conformance into Foundation, so you need to import Foundation to take
advantage of it. A comment [in the Foundation source
code](https://github.com/apple/swift/blob/master/stdlib/public/SDK/Foundation/ExtraStringAPIs.swift)
explains why:

``` swift-example
// Random access for String.UTF16View, only when Foundation is
// imported.  Making this API dependent on Foundation decouples the
// Swift core from a UTF16 representation.
...
extension String.UTF16View : RandomAccessCollection {}
```

Nothing would break if a future `String` implementation used a different
internal representation. Existing code that relied on the random-access
conformance could take advantage of the option for a `String` to be backed by an
`NSString`, like we discussed above. `NSString` also uses UTF-16 internally.

That said, it's probably rarer than you think to need random access. Most
practical string use cases just need serial access. But some processing
algorithms rely on random access for efficiency. For example, the Boyer-Moore
search algorithm relies on the ability to skip along the text in jumps of
multiple characters.

So you could use the UTF-16 view with algorithms that require such a
characteristic. Another example is the search algorithm we define in the
generics chapter:

*/

//#-hidden-code
import Foundation

extension Collection
    where Iterator.Element: Equatable,
        SubSequence.Iterator.Element == Iterator.Element,
        Indices.Iterator.Element == Index
{
    func search<Other: Sequence>(for pattern: Other) -> Index?
        where Other.Iterator.Element == Iterator.Element
    {
        return indices.first { idx in
            suffix(from: idx).starts(with: pattern)
        }
    }
}
//#-end-hidden-code

//#-editable-code
let helloWorld = "Hello, world!"
if let idx = helloWorld.utf16.search(for: "world".utf16)?
    .samePosition(in: helloWorld)
{
    print(helloWorld[idx..<helloWorld.endIndex])
}
//#-end-editable-code

/*:
But beware\! These convenience or efficiency benefits come at a price, which is
that your code may no longer be completely Unicode-correct. So unfortunately,
the following search will fail:

*/

//#-editable-code
let text = "Look up your Pok\u{0065}\u{0301}mon in a Pokédex."
text.utf16.search(for: "Pokémon".utf16)
//#-end-editable-code

/*:
Unicode defines diacritics that are used to combine with alphabetic characters
as being alphanumeric, so this fares a little better:

*/

//#-editable-code
let nonAlphas = CharacterSet.alphanumerics.inverted
text.unicodeScalars.split(whereSeparator: nonAlphas.contains).map(String.init)
//#-end-editable-code

