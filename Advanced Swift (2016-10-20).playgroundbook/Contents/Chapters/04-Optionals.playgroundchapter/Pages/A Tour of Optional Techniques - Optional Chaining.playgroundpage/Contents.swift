/*:
### Optional Chaining

In Objective-C, sending a message to `nil` is a no-op. In Swift, the same effect
can be achieved via "optional chaining":

``` swift-example
delegate?.callback()
```

Unlike with Objective-C, though, the compiler will warn you when your value
might be optional. If your value is non-optional, you're guaranteed that the
method will actually be called. If not, the `?` is a clear signal to the reader
that it might not be called.

When the method you call via optional chaining returns a result, that result
will also be optional. Consider the following code to see why this must be the
case:

*/

//#-editable-code
let str: String? = "Never say never"
// We want upper to be the uppercase string
let upper: String
if str != nil {
    upper = str!.uppercased()
} else {
    // No reasonable action to take at this point
    fatalError("No idea what to do now...")
}
//#-end-editable-code

/*:
If `str` is non-`nil`, `upper` will have the desired value. But if `str` is
`nil`, then `upper` can't be set to a value. So in the optional chaining case,
`result` *must* be optional, in order to account for the possibility that `str`
could've been `nil`:

*/

//#-editable-code
let result = str?.uppercased()
//#-end-editable-code

/*:
As the name implies, you can chain calls on optional values:

*/

//#-editable-code
let lower = str?.uppercased().lowercased()
//#-end-editable-code

/*:
However, this might look a bit surprising. Didn't we just say that the result of
optional chaining is an optional? So why don't you need a `?.` after
`uppercased()`? This is because optional chaining is a "flattening" operation.
If `str?.uppercased()` returned an optional and you called `?.lowercased()` on
it, then logically you'd get an optional optional. But you just want a regular
optional, so instead we write the second chained call without an optional to
represent the fact that the optionality is already captured.

On the other hand, if the `uppercased` method itself returned an optional, then
you'd need a `?` after it to express that you were chaining *that* optional. For
example, let's imagine adding a computed property, `half`, on the `Int` type.
This property returns the result of dividing the integer by two, but only if the
number is big enough to be divided. When the number is smaller than two, it
returns `nil`:

*/

//#-editable-code
extension Int {
    var half: Int? {
        guard self > 1 else { return nil }
        return self / 2
    }
}
//#-end-editable-code

/*:
Because calling `half` returns an optional result, we need to keep putting in
`?` when calling it repeatedly. After all, at every step, the function might
return `nil`:

*/

//#-editable-code
20.half?.half?.half
//#-end-editable-code

/*:
Optional chaining also applies to subscript and function calls — for example:

*/

//#-editable-code
let dictOfArrays = ["nine": [0, 1, 2, 3]]
dictOfArrays["nine"]?[3]
//#-end-editable-code

/*:
Additionally, you can use optional chaining to call optional functions:

*/

//#-editable-code
let dictOfFuncs: [String: (Int, Int) -> Int] = [
    "add": (+),
    "subtract": (-)
]
dictOfFuncs["add"]?(1, 1)
//#-end-editable-code

/*:
You can even assign *through* an optional chain. Suppose you have an optional
variable, and if it's non-`nil`, you wish to update one of its properties:

*/

//#-hidden-code
import UIKit
//#-end-hidden-code

let splitViewController: UISplitViewController? = nil
let myDelegate: UISplitViewControllerDelegate? = nil
if let viewController = splitViewController {
    viewController.delegate = myDelegate
}

/*:
Instead, you can assign to the chained optional value, and if it isn't `nil`,
the assignment will work:

*/

splitViewController?.delegate = myDelegate
