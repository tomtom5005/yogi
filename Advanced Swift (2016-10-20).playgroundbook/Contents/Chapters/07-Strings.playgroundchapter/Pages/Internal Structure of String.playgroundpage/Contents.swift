/*:
## Internal Structure of `String`

(Note: this section describes the internal organization of `Swift.String`. While
it's correct as of Swift 3.0, it should never be relied on for production use,
as it could change at any time. It's presented more to help you understand the
performance characteristics of Swift strings. If you want to follow along, check
out the source code in
[`String.swift`](https://github.com/apple/swift/blob/master/stdlib/public/core/String.swift)
and
[`StringCore.swift`](https://github.com/apple/swift/blob/master/stdlib/public/core/StringCore.swift).)

A string's internal storage is made up of something that looks like this:

``` swift-example
struct String {
    var _core: _StringCore
}
struct _StringCore {
    var _baseAddress: UnsafeMutableRawPointer?
    var _countAndFlags: UInt
    var _owner: AnyObject?
}
```

The `_core` property is currently public and therefore easily accessible. But
even if that were to change in a future release, you'd still be able to bitcast
any string to `_StringCore`:

*/

//#-editable-code
let hello = "hello"
let bits = unsafeBitCast(hello, to: _StringCore.self)
//#-end-editable-code

/*:
(While strings really aggregate an internal type, because they're structs and
thus have no overhead other than their members, you can just bitcast the outer
container without a problem.)

That's enough to print out the contents using `print(bits)`, but you'll notice
that you can't access the individual fields, such as `_countAndFlags`, because
they're private. To work around this, we can duplicate the `_StringCore` struct
in our own code and do another bitcast:

*/

//#-editable-code
/// A clone of Swift._StringCore to work around access control
struct StringCoreClone {
    var _baseAddress: UnsafeMutableRawPointer?
    var _countAndFlags: UInt
    var _owner: AnyObject?
}

let clone = unsafeBitCast(bits, to: StringCoreClone.self)
clone._countAndFlags
//#-end-editable-code

/*:
You'll see that `_countAndFlags` is `5`, the length of the string. The base
address is a pointer to memory holding the sequence of ASCII characters. You can
print out this buffer using the C `puts` function. `puts` expects an `Int8`
pointer, so you have to convert the untyped pointer to `UnsafePointer<Int8>`
first:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
if let pointer = clone._baseAddress?.assumingMemoryBound(to: Int8.self) {
    puts(pointer)
}
//#-end-editable-code

/*:
The above will print out `hello`. Or it might print out `hello`, followed by a
bunch of garbage, because the buffer isn't necessarily null-terminated like a
regular C string.

So, does this mean Swift uses a UTF-8 representation to store strings
internally? You can find out by storing a non-ASCII string instead:

*/

//#-editable-code
let emoji = "Hello, 🌏"
let emojiBits = unsafeBitCast(emoji, to: StringCoreClone.self)
emojiBits._countAndFlags
//#-end-editable-code

/*:
If you do this, you'll see two differences from before. One is that the
`_countAndFlags` property is now a huge number. This is because it isn't just
holding the length. The high-order bits are used to store a flag indicating that
this string includes non-ASCII values (there's also another flag indicating the
string points to the buffer of an `NSString`). Conveniently, `_StringCore` has a
public `count` property that returns the length in code units:

*/

//#-editable-code
emoji._core.count
//#-end-editable-code

/*:
The second change is that the `_baseAddress` now points to 16-bit characters.
This is reflected in the `elementWidth` property:

*/

//#-editable-code
emoji._core.elementWidth
//#-end-editable-code

/*:
Now that one or more of the characters is no longer ASCII, it triggers `String`
to start storing the buffer as UTF-16. It does this no matter which non-ASCII
characters you store in the string — even if they require 32 bits to store,
there isn't a third mode where UTF-32 is used.

The last `_StringCore` property, `_owner`, will be a null pointer:

*/

//#-editable-code
emojiBits._owner
//#-end-editable-code

/*:
This is because all the strings thus far have been initialized via a string
literal, so the buffer points to a constant string in memory in the read-only
data part of the binary. Let's see what happens when we create a non-constant
string:

*/

//#-editable-code
var greeting = "hello"
greeting.append(" world")
let greetingBits = unsafeBitCast(greeting, to: StringCoreClone.self)
greetingBits._owner
//#-end-editable-code

/*:
This string's `_owner` field contains a value. This will be a pointer to an
ARC-managed class reference, used in conjunction with a function like
`isKnownUniquelyReferenced`, to give strings value semantics with copy-on-write
behavior.

This `_owner` manages the memory allocated to hold the string. The picture we've
built up so far looks something like this:

![Memory of a `String` value](artwork/strings-memory.png)

Since the owner is a class, this means it can have a `deinit` method, which,
when triggered, frees the memory:

![When a `String` goes out of scope](artwork/strings-deinit.png)

Strings, like arrays and other standard library collection types, are
copy-on-write. When you assign a string to a second string variable, the string
buffer isn't copied immediately. Instead, as with any copy assignment of a
struct, a shallow copy of only the immediate fields takes place, and they
initially share that storage:

![Two `String`s share the same memory](artwork/strings-sharing.png)

Then, when one of the strings mutates its contents, the code detects this
sharing by checking whether or not the `_owner` is uniquely referenced. If it
isn't, it first copies the shared buffer before mutating it, at which point the
buffer is no longer shared:

![String Mutation](artwork/strings-copying.png)

For more on copy-on-write, see the chapter on structs and classes.

One final benefit of this structure returns us to slicing. If you take a string
and create slices from it, the internals of these slices look like this:

![String Slices](artwork/strings-slices.png)

This means that when calling `split` on a string, what you're essentially
creating is an array of starting/ending pointers to within the original string
buffer, as opposed to making numerous copies. This comes at a cost, though — a
single slice of a string keeps the whole string in memory. Even if that slice is
just a few characters, it could be keeping a string of several megabytes alive.

If you create a `String` from an `NSString`, then another optimization means the
`_owner` reference used will actually be a reference to the original `NSString`,
and the buffer will point to that `NSString`'s storage. This can be shown by
extracting the owner reference *as* an `NSString`, so long as the string was
originally an `NSString`:

*/

//#-editable-code
let ns = "hello" as NSString
let s = ns as String
let nsBits = unsafeBitCast(s, to: StringCoreClone.self)
nsBits._owner is NSString
nsBits._owner === ns
//#-end-editable-code

/*:
### Internal Organization of `Character`

As we've seen, `Swift.Character` represents a sequence of code points that might
be arbitrarily long. How does `Character` manage this? If you look at the
[source
code](https://github.com/apple/swift/blob/master/stdlib/public/core/Character.swift),
you'll find that `Character` is essentially defined like this:

``` swift-example
struct Character {
   enum Representation {
       case large(Buffer)
       case small(Builtin.Int63)
   }

   var _representation: Representation
}
```

This technique — holding a small number of elements internally and switching to
a heap-based buffer — is sometimes called the "small string optimization." Since
characters are almost always just a handful of bytes, it works particularly well
here.

`Builtin.Int63` is an internal LLVM type that's only available to the standard
library. The unusual size of 63 bits indicates another possible optimization.
Since one bit is needed to discriminate between the two enum cases, 63 is the
maximum available width to fit the entire struct in a single machine word. This
currently has no effect though, because the associated value for the `large`
case is a pointer that occupies the full 64 bits. Pointer alignment rules mean
that some bits of a valid object pointer will always be zero, and these could
potentially be used as storage for the enum case tag, but this particular
optimization [isn't implemented in
Swift 3.0](https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20160822/002747.html).
As a result, a `Character` is nine bytes long:

*/

//#-editable-code
MemoryLayout<Character>.size
//#-end-editable-code

