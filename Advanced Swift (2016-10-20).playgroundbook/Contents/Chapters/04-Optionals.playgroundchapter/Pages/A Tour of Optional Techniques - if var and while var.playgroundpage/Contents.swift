/*:
### `if var` and `while var`

Instead of `let`, you can use `var` with `if`, `while`, and `for`:

*/

//#-editable-code
let number = "1"
if var i = Int(number) {
    i += 1
    print(i)
}
//#-end-editable-code

/*:
But note that `i` will be a local copy; any changes to `i` won't affect the
value inside the original optional. Optionals are value types, and unwrapping
them unwraps the value inside.

### Scoping of Unwrapped Optionals

Sometimes it feels frustrating to only have access to an unwrapped variable
within the `if` block it has defined. But really, this is no different than
other techniques.

For example, take the `first` computed property on arrays — a property that
returns an optional of the first element, or `nil` when the array is empty. This
is convenient shorthand for the following common bit of code:

*/

//#-editable-code
let array = [1,2,3]
if !array.isEmpty {
    print(array[0])
}
// Outside the block, no guarantee that array[0] is valid
//#-end-editable-code

/*:
Using the `first` property, you *have* to unwrap the optional in order to use it
— you can't accidentally forget:

*/

//#-editable-code
if let firstElement = array.first {
    print(firstElement)
}
// Outside the block, you can't use firstElement
//#-end-editable-code

/*:
The big exception to this is an early exit from a function. Sometimes you might
write the following:

*/

//#-editable-code
func doStuff(withArray a: [Int]) {
    guard !a.isEmpty else { return }
    // Now use a[0] safely
}
//#-end-editable-code

/*:
This early exit can help avoid annoying nesting or repeated guards later on in
the function.

One option for using an unwrapped optional outside the scope it was bound in is
to rely on Swift's deferred initialization capabilities. Consider the following
example, which reimplements part of the `pathExtension` property from `URL` and
`NSString`:

*/

//#-editable-code
extension String {
    var fileExtension: String? {
        let period: String.Index
        if let idx = characters.index(of: ".") {
            period = idx
        } else {
            return nil
        }        
        let extensionRange = characters.index(after: period)..<characters.endIndex
        return self[extensionRange]
    }
}

"hello.txt".fileExtension
//#-end-editable-code

/*:
Swift checks your code to confirm that there are only two possible paths: one in
which the function returns early, and another where `period` is properly
initialized. There's no way `period` could be `nil` (it isn't optional) or
uninitialized (Swift won't let you use a variable that hasn't been initialized).
So after the `if` statement, the code can be written without you having to worry
about optionals at all.

*/
