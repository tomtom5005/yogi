/*:
## Automatic Closures

We're all familiar with the short-circuiting of the `&&` operator. It takes two
operands: first, the left operand is evaluated. Only if the left operand
evaluates to `true` is the right operand evaluated. After all, if the left
operand evaluates to `false`, there's no way the entire expression can evaluate
to `true`. Therefore, we can short-circuit and we don't have to evaluate the
right operand. For example, if we want to check if a condition holds for the
first element of an array, we could write the following code:

*/

//#-editable-code
let evens = [2,4,6]
if !evens.isEmpty && evens[0] > 10 {
    // Perform some work
}
//#-end-editable-code

/*:
In the snippet above, we rely on short-circuiting: the array lookup happens only
if the first condition holds. Without short-circuiting, this code would crash on
an empty array.

In almost all languages, short-circuiting is built into the language for the
`&&` and `||` operators. However, it's often not possible to define your own
operators or functions that have short-circuiting. If a language supports
closures, we can fake short-circuiting by providing a closure instead of a
value. For example, let's say we wanted to define an `and` function in Swift
with the same behavior as the `&&` operator:

*/

//#-editable-code
func and(_ l: Bool, _ r: () -> Bool) -> Bool {
    guard l else { return false }
    return r()
}
//#-end-editable-code

/*:
The function above first checks the value of `l` and returns `false` if `l`
evaluates to `false`. Only if `l` is `true` does it return the value that comes
out of the closure `r`. Using it is a little bit uglier than using the `&&`
operator, though, because the right operand now has to be a function:

*/

//#-editable-code
if and(!evens.isEmpty, { evens[0] > 10 }) {
    // Perform some work
}
//#-end-editable-code

/*:
Swift has a nice feature to make this prettier. We can use the `@autoclosure`
attribute to automatically create a closure around an argument. The definition
of `and` is almost the same as above, except for the added `@autoclosure`
annotation:

*/

//#-editable-code
func and(_ l: Bool, _ r: @autoclosure () -> Bool) -> Bool {
    guard l else { return false }
    return r()
}

//#-end-editable-code

/*:
However, the usage of `and` is now much simpler, as we don't need to wrap the
second parameter in a closure. Instead, we can just call it as if it took a
regular `Bool` parameter:

*/

//#-editable-code
if and(!evens.isEmpty, evens[0] > 10) {
    // Perform some work
}
//#-end-editable-code

/*:
This allows us to define our own functions and operators with short-circuiting
behavior. For example, operators like `??` and `!?` (as defined in the chapter
on optionals) are now straightforward to write. In the standard library,
functions like `assert` and `fatalError` also use autoclosures in order to only
evaluate the arguments when really needed. By deferring the evaluation of
assertion conditions from the call sites to the body of the `assert` function,
these potentially expensive operations can be stripped completely in optimized
builds where they're not needed.

Autoclosures can also come in handy when writing logging functions. For example,
here's how you could write your own `log` function, which only evaluates the log
message if the condition is `true`:

*/

//#-editable-code
func log(condition: Bool,
         message: @autoclosure () -> (String),
         file: String = #file, line function: String = #function, line: Int = #line) {
    if condition { return }
    print("myAssert failed: \(message()), \(file):\(function) (line \(line))")
}

log(condition: true, message: "This is a test")
//#-end-editable-code

/*:
The `log` function also uses the debugging identifiers `#file`, `#function`, and
`#line`. They're especially useful when used as a default argument to a
function, because they'll get the values of the filename, function name, and
line number at the call site.

*/
