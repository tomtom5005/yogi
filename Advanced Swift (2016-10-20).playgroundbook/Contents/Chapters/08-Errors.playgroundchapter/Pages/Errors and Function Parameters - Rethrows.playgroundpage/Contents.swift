/*:
### Rethrows

Fortunately, there's a better way. By marking `all` as `rethrows`, we can write
both variants in one go. Annotating a function with `rethrows` tells the
compiler that this function will only throw an error when its function parameter
throws an error. This allows the compiler to waive the requirement that `call`
must be called with `try` when the caller passes in a non-throwing `check`
function:

*/

//#-editable-code
extension Sequence {
    func all(condition: (Iterator.Element) throws -> Bool) rethrows
        -> Bool {
        for element in self {
            guard try condition(element) else { return false }
        }
        return true
    }
}
//#-end-editable-code

/*:
The implementation of `checkAllFiles` is now very similar to `checkPrimes`, but
because the call to `all` can now throw an error, we need to insert an
additional `try`:

*/

//#-hidden-code
struct CheckFileError: Error {}
//#-end-hidden-code

//#-hidden-code
func checkFile(filename: String) throws -> Bool
//#-end-hidden-code

//#-hidden-code
{
    switch filename {
    case "fail.txt": throw CheckFileError()
    case "invalid.txt": return false
    default: return true
    }
}
//#-end-hidden-code

//#-editable-code
func checkAllFiles(filenames: [String]) throws -> Bool {
    return try filenames.all(condition: checkFile)
}
//#-end-editable-code

/*:
Almost all sequence and collection functions in the standard library that take a
function argument are annotated with `rethrows`. For example, the `map` function
is only throwing if the transformation function is a throwing function itself.

*/
