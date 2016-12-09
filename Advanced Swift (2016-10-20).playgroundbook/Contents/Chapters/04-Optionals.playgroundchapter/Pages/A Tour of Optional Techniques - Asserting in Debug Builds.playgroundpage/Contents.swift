/*:
### Asserting in Debug Builds

Still, choosing to crash even on release builds is quite a bold move. Often, you
might prefer to assert during debug and test builds, but in production, you'd
substitute a valid default value — perhaps zero or an empty array.

Enter the interrobang operator, `!?`. We define this operator to assert on
failed unwraps and also to substitute a default value when the assertion doesn't
trigger in release mode:

*/

//#-editable-code
infix operator !?

func !?<T: ExpressibleByIntegerLiteral>
    (wrapped: T?, failureText: @autoclosure () -> String) -> T
{
    assert(wrapped != nil, failureText())
    return wrapped ?? 0
}

//#-end-editable-code

/*:
Now, the following will assert while debugging but print `0` in release:

*/

//#-editable-code
let s = "20"
let i = Int(s) !? "Expecting integer, got \"\(s)\""
//#-end-editable-code

/*:
Overloading for other literal convertible protocols enables a broad coverage of
types that can be defaulted:

*/

//#-editable-code
func !?<T: ExpressibleByArrayLiteral>
    (wrapped: T?, failureText: @autoclosure () -> String) -> T
{
    assert(wrapped != nil, failureText())
    return wrapped ?? []
}

func !?<T: ExpressibleByStringLiteral>
    (wrapped: T?, failureText: @autoclosure () -> String) -> T
{
    assert(wrapped != nil, failureText)
    return wrapped ?? ""
}
//#-end-editable-code

/*:
And for when you want to provide a different explicit default, or for
non-standard types, we can define a version that takes a pair — the default and
the error text:

*/

//#-editable-code
func !?<T>(wrapped: T?,
    nilDefault: @autoclosure () -> (value: T, text: String)) -> T
{
    assert(wrapped != nil, nilDefault().text)
    return wrapped ?? nilDefault().value
}

// Asserts in debug, returns 5 in release
Int(s) !? (5, "Expected integer")
//#-end-editable-code

/*:
Since optionally chained method calls on methods that return `Void` return
`Void?`, you can also write a non-generic version to detect when an optional
chain hits a `nil`, resulting in a no-op:

*/

//#-editable-code
func !?(wrapped: ()?, failureText: @autoclosure () -> String) {
    assert(wrapped != nil, failureText)
}
//#-end-editable-code

/*:
``` swift-example
var output: String? = nil
output?.write("something") !? "Wasn't expecting chained nil here"
```

There are three ways to halt execution. The first option, `fatalError`, takes a
message and stops execution unconditionally. The second option, `assert`, checks
a condition and a message and stops execution if the condition evaluates to
`false`. In release builds, the `assert` gets removed — the condition isn't
checked (and execution is never halted). The third option is `precondition`,
which has the same interface as `assert`, but doesn't get removed from release
builds, so if the condition evaluates to `false`, execution is stopped.

*/
