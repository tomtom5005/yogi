/*:
# Strings 

## No More Fixed Width

Things used to be so simple. ASCII strings were a sequence of integers between 0
and 127. If you stored them in an 8-bit byte, you even had a bit to spare\!
Since every character was of a fixed size, ASCII strings could be random access.

But this is only if you were writing in English for a U.S. audience; other
countries and languages needed other characters (even English-speaking Britain
needed a £ sign). Most of them needed more characters than would fit into seven
bits. ISO/IEC 8859 takes the extra bit and defines 16 different encodings above
the ASCII range, such as Part 1 (ISO/IEC 8859-1, aka Latin-1), covering several
Western European languages; and Part 5, covering languages that use the Cyrillic
alphabet.

But this is still limiting. If you want use ISO/IEC 8859 to write in Turkish
about Ancient Greek, you're out of luck, since you'd need to pick either Part 7
(Latin/Greek) or Part 9 (Turkish). And eight bits is still not enough to encode
many languages. For example, Part 6 (Latin/Arabic) doesn't include the
characters needed to write Arabic-script languages such as Urdu or Persian.
Meanwhile, Vietnamese — which is based on the Latin alphabet but with a large
number of diacritic combinations — only fits into eight bits by replacing a
handful of ASCII characters from the lower half. And this isn't even an option
for other East Asian languages.

When you run out of room with a fixed-width encoding, you have a choice: either
increase the size, or switch to variable-width encoding. Initially, Unicode was
defined as a 2-byte fixed-width format, now called UCS-2. This was before
reality set in, and it was accepted that even two bytes would not be sufficient,
while four would be horribly inefficient for most purposes.

So today, Unicode is a variable-width format, and it's variable in two different
senses: in the combining of code units into code points, and in the combining of
code points into characters.

Unicode data can be encoded with many different widths of "code unit," most
commonly 8 (UTF-8) or 16 (UTF-16) bits. UTF-8 has the added benefit of being
backwardly compatible with 8-bit ASCII — something that's helped it overtake
ASCII as the most popular encoding on the web.

A "code point" in Unicode is a single value in the Unicode code space with a
possible value from `0` to `0x10FFFF`. Only about 128,000 of the 1.1 million
code points possible are currently in use, so there's a lot of room for more
emoji. A given code point might take a single code unit if you're using UTF-32,
or it might take between one and four if you're using UTF-8. The first 256
Unicode code points match the characters found in Latin-1.

Unicode "scalars" are another unit. They're all the code points *except* the
"surrogate" code points, i.e. the code points used for the leading and trailing
codes that indicate pairs in UTF-16 encoding. Scalars are represented in Swift
string literals as `"\u{xxxx}"`, where xxxx represents hex digits. So the euro
sign, €, can be written in Swift as `"\u{20AC}"`.

But even when encoded using 32-bit code units, what a user might consider "a
single character" — as displayed on the screen — might require multiple code
points composed together. Most string manipulation code exhibits a certain level
of denial about Unicode's variable-width nature. This can lead to some
unpleasant bugs.

Swift's string implementation goes to heroic efforts to be as Unicode-correct as
possible, or at least when it's not, to make sure you acknowledge the fact. This
comes at a price. `String` in Swift isn't a collection. Instead, it's a type
that presents multiple ways of viewing the string: as a collection of
`Character` values; or as a collection of UTF-8, UTF-16, or Unicode scalars.

The Swift `Character` type is unlike the other views, in that it can encode an
arbitrary number of code points, composed together into a single "grapheme
cluster." We'll see some examples of this shortly.

For all but the UTF-16 view, these views do *not* support random access, i.e.
measuring the distance between two indices or advancing an index by some number
of steps is generally not an `O(1)` operation. Even the UTF-16 view is only
random access when you import Foundation (more on that below). Some of the views
can also be slower than others when performing heavy text processing. In this
chapter, we'll look at the reasons behind this, as well as some techniques for
dealing with both functionality and performance.

### Grapheme Clusters and Canonical Equivalence

A quick way to see the difference between `Swift.String` and `NSString` in
handling Unicode data is to look at the two different ways to write é. Unicode
defines U+00E9, "LATIN SMALL LETTER E WITH ACUTE," as a single value. But you
can also write it as the plain letter e, followed by U+0301, "COMBINING ACUTE
ACCENT." In both cases, what's displayed is é, and a user probably has a
reasonable expectation that two strings displayed as "résumé" would not only be
equal to each other but also have a "length" of six characters, no matter which
technique was used to produce the é in either one. They would be what the
Unicode specification describes as "canonically equivalent."

And in Swift, this is exactly the behavior you get:

*/

//#-editable-code
let single = "Pok\u{00E9}mon"
let double = "Pok\u{0065}\u{0301}mon"
//#-end-editable-code

/*:
They both display identically:

*/

//#-editable-code
(single, double)
//#-end-editable-code

/*:
And both have the same character count:

*/

//#-editable-code
single.characters.count
double.characters.count
//#-end-editable-code

/*:
Only if you drop down to a view of the underlying representation can you see
that they're different:

*/

//#-editable-code
single.utf16.count
double.utf16.count
//#-end-editable-code

/*:
Contrast this with `NSString`: the two strings aren't equal, and the `length`
property — which many programmers probably use to count the number of characters
to be displayed on the screen — gives different results:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
let nssingle = NSString(characters: [0x0065,0x0301], length: 2)
nssingle.length
let nsdouble = NSString(characters: [0x00e9], length: 1)
nsdouble.length
nssingle == nsdouble
//#-end-editable-code

/*:
Here, `==` is defined as the version for comparing two `NSObject`s:

``` swift-example
extension NSObject: Equatable {
    static func ==(lhs: NSObject, rhs: NSObject) -> Bool {
        return lhs.isEqual(rhs)
    }
}
```

In the case of `NSString`, this will do a literal comparison, rather than one
accounting for equivalent but differently composed characters.
`NSString.isEqualToString` will do the same, and most string APIs in other
languages work this way too. If you really want to perform a canonical
comparison, you must use `NSString.compare`. Didn't know that? Enjoy your future
undiagnosable bugs and grumpy international user base.

Of course, there's one big benefit to just comparing code units: it's a lot
faster\! This is an effect that can still be achieved with Swift strings, via
the `utf16` view:

*/

//#-editable-code
single.utf16.elementsEqual(double.utf16)
//#-end-editable-code

/*:
Why does Unicode support multiple representations at all? The existence of
precomposed characters is what enables the opening range of Unicode code points
to be compatible with Latin-1, which already had characters like é and ñ. While
they might be a pain to deal with, it makes conversion between the two quick and
simple.

Ditching them wouldn't have helped, because composition doesn't just stop at
pairs; you can compose more than one diacritic together. For example, Yoruba has
the character ọ́, which could be written three different ways: by composing ó
with a dot, or by composing ọ with an acute, or by composing o with both an
acute and a dot. And for that last one, the two diacritics can be in either
order\! So these are all equal:

*/

//#-hidden-code
extension Sequence {
    func all(matching predicate: (Iterator.Element) throws -> Bool) rethrows -> Bool {
        for x in self where try !predicate(x) {
            return false
        }
        return true
    }
}
//#-end-hidden-code

//#-editable-code
let chars: [Character] = [
    "\u{1ECD}\u{300}",      // ọ́
    "\u{F2}\u{323}",        // ọ́
    "\u{6F}\u{323}\u{300}", // ọ́
    "\u{6F}\u{300}\u{323}"  // ọ́
]
chars.dropFirst().all { $0 == chars.first }
//#-end-editable-code

/*:
(The `all` method checks if the condition is true for all elements in a sequence
and is defined in the chapter on built-in collections.)

In fact, some diacritics can be added ad infinitum:

*/

//#-editable-code
let zalgo = "s̼̐͗͜o̠̦̤ͯͥ̒ͫ́ͅo̺̪͖̗̽ͩ̃͟ͅn̢͔͖͇͇͉̫̰ͪ͑"

zalgo.characters.count
zalgo.utf16.count
//#-end-editable-code

/*:
In the above, `zalgo.characters.count` returns 4, while `zalgo.utf16.count`
returns 36. And if your code doesn't work correctly with Internet memes, then
what good is it, really?

Strings containing emoji can also be a little surprising. For example, a row of
emoji flags is considered a single character:

*/

//#-editable-code
let flags = "🇳🇱🇬🇧"
flags.characters.count
// The scalars are the underlying ISO country codes:
flags.unicodeScalars.map { String($0) }.joined(separator: ",")
//#-end-editable-code

/*:
On the other hand, `"👩🏾".characters.count` returns 2 (one for the generic
character, one for the skin tone), and `"👨‍👨‍👧‍👧".characters.count` returns 4 in
Swift 3.0, as the multi-person groupings are composed from individual member
emoji joined with the zero-width joiner:

*/

//#-editable-code
"👩🏾".characters.count
"👨‍👨‍👧‍👧".characters.count
"👩\u{200D}👩\u{200D}👦\u{200D}👦" == "👩‍👩‍👦‍👦"
//#-end-editable-code

/*:
While counting the concatenated flags as one character is a weird but expected
behavior, these emoji should really be treated as a single character. [Expect
these results to change](https://bugs.swift.org/browse/SR-2413) as soon as Swift
updates its rules for grapheme cluster boundaries to Unicode 9.0, which was
released in June 2016.

*/

