/*:
### Chaining Result

To see how well Swift's native error handling matches up against other error
handling schemes, let's compare this to an equivalent example based on the
`Result` type. Chaining multiple functions that return a `Result` — where the
input to the second function is the result of the first — is a lot of work if
you want to do it manually. To do so, you call the first function and unwrap its
return value; if it's a `.success`, you can pass the wrapped value to the second
function and start over. As soon as one function returns a `.failure`, the chain
breaks and you short-circuit by immediately returning the failure to the caller.

To refactor this, we should turn the common steps of unwrapping the `Result`,
short-circuiting in case of failure, and passing the value to the next
transformation in case of success, into a separate function. That function is
the `flatMap` operation. Its structure is identical to the existing `flatMap`
for optionals that we covered in the optionals chapter:

*/

//#-editable-code
extension Result {
    func flatMap<B>(transform: (A) -> Result<B>) -> Result<B> {
        switch self {
        case let .failure(m): return .failure(m)
        case let .success(x): return transform(x)
        }
    }
}
//#-end-editable-code

/*:
With this in place, the end result is quite elegant:

*/

//#-hidden-code
enum Result<A> {
    case failure(Error)
    case success(A)
}
//#-end-hidden-code

//#-hidden-code
struct CheckFileError: Error {}
//#-end-hidden-code

//#-hidden-code
enum FileError: Error {
    case fileDoesNotExist
    case noPermission
}
//#-end-hidden-code

//#-hidden-code
enum ReadIntError: Error {
    case couldNotRead
}
//#-end-hidden-code

//#-hidden-code
extension Sequence {
    func all(condition: (Iterator.Element) -> Result<Bool>) -> Result<Bool> {
        for element in self {
            let value = condition(element)
            switch value {
            case .success(true): continue
            default: return value
            }
        }
        return .success(true)
    }
}

func checkFile(filename: String) -> Result<Bool> {
    switch filename {
    case "fail.txt": return .failure(CheckFileError())
    case "invalid.txt": return .success(false)
    default: return .success(true)
    }
}

func contents(ofFile filename: String) -> Result<String> {
    switch filename {
    case "notfound.txt": return .failure(FileError.fileDoesNotExist)
    case "nopermission.txt": return .failure(FileError.noPermission)
    case "Pidfile": return .success("11111")
    default: return .success("This is a dummy return value. Pass \"notfound.txt\" or \"nopermission.txt\" as the filename to have this function throw an error.")
    }
}
//#-end-hidden-code

//#-editable-code
func checkFilesAndFetchProcessID(filenames: [String]) -> Result<Int> {
    return filenames
        .all(condition: checkFile)
        .flatMap { _ in contents(ofFile: "Pidfile") }
        .flatMap { contents in
            Int(contents).map(Result.success)
                ?? .failure(ReadIntError.couldNotRead)
    }
}
//#-end-editable-code

/*:
(We're using variants of `all`, `checkFile`, and `contents(ofFile:)` here that
return `Result` values. The implementations aren't shown here.)

But you can also see that Swift's error handling stands up extremely well. It's
shorter, and it's arguably more readable and easier to understand.

*/
