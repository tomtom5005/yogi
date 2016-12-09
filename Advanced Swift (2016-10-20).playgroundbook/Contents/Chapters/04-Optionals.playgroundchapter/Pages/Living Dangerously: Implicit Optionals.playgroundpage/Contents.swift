/*:
## Living Dangerously: Implicit Optionals

Make no mistake: implicit optionals are still optionals — ones that are
automatically force-unwrapped whenever you use them. Now that we know that
force-unwraps will crash your application if they're ever `nil`, why on earth
would you use them? Well, two reasons really.

Reason 1: Temporarily, because you're calling code that hasn't been audited for
nullability into Objective-C.

Of course, on the first day you start writing Swift against your existing
Objective-C, any Objective-C method that returns a reference will translate into
an implicitly unwrapped optional. Since, for most of Objective-C's lifetime,
there was no way to indicate that a reference was nullable, there was little
option other than to assume any call returning a reference might return a `nil`
reference. But few Objective-C APIs *actually* return null references, so it'd
be incredibly annoying to automatically expose them as optionals. Since everyone
was used to dealing with the "maybe null" world of Objective-C objects,
implicitly unwrapped optionals were a reasonable compromise.

So you see them in unaudited bridged Objective-C code. But you should *never*
see a pure native Swift API returning an implicit optional (or passing one into
a callback).

Reason 2: Because a value is `nil` *very* briefly, for a well-defined period of
time, and is then never `nil` again.

For example, if you have a two-phase initialization, then by the time your class
is ready to use, the implicitly wrapped optionals will all have a value. This is
the reason Xcode/Interface Builder uses them.

### Implicit Optional Behavior

While implicitly unwrapped optionals usually behave like non-optional values,
you can still use most of the unwrap techniques to safely handle them like
optionals — chaining, `nil`-coalescing, `if let`, and `map` all work the same:

*/

//#-editable-code
var s: String! = "Hello"
s?.isEmpty
if let s = s { print(s) }
s = nil
s ?? "Goodbye"
//#-end-editable-code

/*:
As much as implicit optionals try to hide their optional-ness from you, there
are a few times when they behave slightly differently. For example, you can't
pass an implicit optional into a function that takes the wrapped type as an
`inout`:

``` swift-example
func increment(_ x: inout Int) {
      x += 1
}

var i = 1     // Regular Int
increment(&i) // Increments i to 2

var j: Int! = 1 // Implicitly unwrapped Int
increment(&j)   // Error: Cannot pass immutable value of type 'Int' as inout argument
```

*/
