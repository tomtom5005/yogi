/*:
## Chaining Errors

Chaining multiple calls to functions that can throw errors becomes trivial with
Swift's built-in error handling — there's no need for nested `if` statements or
similar constructs; we simply place these calls into a single `do`/`catch` block
(or wrap them in a throwing function). The first error that occurs breaks the
chain and switches control to the `catch` block (or propagates the error to the
caller):

*/

//#-hidden-code
extension Sequence {
    func all(condition: (Iterator.Element) throws -> Bool) rethrows
        -> Bool {
        for element in self {
            guard try condition(element) else { return false }
        }
        return true
    }
}
//#-end-hidden-code

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

//#-hidden-code
enum FileError: Error {
    case fileDoesNotExist
    case noPermission
}
//#-end-hidden-code

//#-hidden-code
func contents(ofFile filename: String) throws -> String
//#-end-hidden-code

//#-hidden-code
{
    switch filename {
    case "notfound.txt": throw FileError.fileDoesNotExist
    case "nopermission.txt": throw FileError.noPermission
    case "Pidfile": return "11111" // Used below in the Chaining Errors section
    default: return "This is a dummy return value. Pass \"notfound.txt\" or \"nopermission.txt\" as the filename to have this function throw an error."
    }
}
//#-end-hidden-code

//#-hidden-code
extension Optional {
    /// Unwraps `self` if it is non-`nil`.
    /// Throws the given error if `self` is `nil`.
    func or(error: Error) throws -> Wrapped {
        switch self {
            case let x?: return x
            case nil: throw error
        }
    }
}
//#-end-hidden-code

//#-hidden-code
enum ReadIntError: Error {
    case couldNotRead
}
//#-end-hidden-code

//#-editable-code
func checkFilesAndFetchProcessID(filenames: [String]) -> Int {
    do {
        try filenames.all(condition: checkFile)
        let pidString = try contents(ofFile: "Pidfile")
        return try Int(pidString).or(error: ReadIntError.couldNotRead)
    } catch {
        return 42 // Default value
    }
}
//#-end-editable-code
