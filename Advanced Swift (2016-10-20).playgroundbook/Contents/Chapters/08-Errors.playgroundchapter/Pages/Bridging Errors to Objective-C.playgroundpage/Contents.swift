/*:
## Bridging Errors to Objective-C

Objective-C has no mechanism that's similar to `throws` and `try`. (Objective-C
*does* have exception handling that uses these same keywords, but exceptions in
Objective-C should only be used to signal programmer errors. You rarely catch an
Objective-C exception in a normal app.)

Instead, the common pattern in Cocoa is that a method returns `NO` or `nil` when
an error occurs. In addition, failable methods take a reference to an `NSError`
pointer as an extra argument; they can use this pointer to pass concrete error
information to the caller. For example, the `contents(ofFile:)` method would
look like this in Objective-C:

``` objc
- (NSString *)contentsOfFile(NSString *)filename error:(NSError **)error;
```

Swift automatically translates methods that follow this pattern to the `throws`
syntax. The error parameter gets removed since it's no longer needed, and `BOOL`
return types are changed to `Void`. This is extremely helpful when dealing with
existing frameworks in Objective-C. The method above gets imported like this:

``` swift-example
func contents(ofFile filename: String) throws -> String
```

Other `NSError` parameters — for example, in asynchronous APIs that pass an
error back to the caller in a completion block — are bridged to the `Error`
protocol, so you don't generally need to interact with `NSError` directly.
`Error` has only one property, `localizedDescription`. For pure Swift errors
that don't override this, the runtime will generate a default text derived from
the type name, but if you intend your error values to be presented to the user,
it's good practice to provide a meaningful description.

If you pass a pure Swift error to an Objective-C method, it'll similarly be
bridged to `NSError`. Since all `NSError` objects must have a `domain` string
and an integer error `code`, the runtime will again provide default values,
using the type name as the domain and numbering the enum cases from zero for the
error code. Optionally, you can provide better implementations by conforming
your type to the `CustomNSError` protocol.

For example, we could extend our `ParseError` like this:

*/

//#-hidden-code
enum ParseError: Error {
    case wrongEncoding
    case warning(line: Int, message: String)
}
//#-end-hidden-code

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
extension ParseError: CustomNSError {
    static let errorDomain = "io.objc.parseError"
    var errorCode: Int {
        switch self {
        case .wrongEncoding: return 100
        case .warning(_, _): return 200
        }
    }
    var errorUserInfo: [String: Any] {
        return [:]
    }
}
//#-end-editable-code

/*:
In a similar manner, you can add conformance to one or both of the following
protocols to make your errors more meaningful and provide better
interoperability with Cocoa conventions:

  - **`LocalizedError`** — provides localized messages describing why the error
    occurred (`failureReason`), tips for how to recover (`recoverySuggestion`),
    and additional help text (`helpAnchor`).

  - **`RecoverableError`** — describes an error the user can recover from by
    presenting one or more `recoveryOptions` and performing the recovery when
    the user requests it.

*/
