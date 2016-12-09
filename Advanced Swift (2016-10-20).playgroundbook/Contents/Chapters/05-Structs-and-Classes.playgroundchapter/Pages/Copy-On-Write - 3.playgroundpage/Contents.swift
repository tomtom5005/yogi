/*:
If we naively wrap `NSMutableData` in a struct, we don't get value semantics
automatically. For example, we could try the following:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
struct MyData {
    var _data: NSMutableData
    init(_ data: NSData) {
        self._data = data.mutableCopy() as! NSMutableData
    }
}
//#-end-editable-code

//#-hidden-code
extension MyData: CustomDebugStringConvertible {
    var debugDescription: String {
        return _data.debugDescription
    }
}
//#-end-hidden-code

/*:
If we copy a struct variable, a shallow bitwise copy is made. This means that
the reference to the object, and not the object itself, will get copied:

*/

//#-editable-code
let theData = NSData(base64Encoded: "wAEP/w==", options: [])!
let x = MyData(theData)
let y = x
x._data===y._data
//#-end-editable-code

/*:
We can add an `append` function, which delegates to the underlying `_data`
property, and again, we can see that we've created a struct without value
semantics:

*/

//#-editable-code
extension MyData {
    func append(_ other: MyData) {
        _data.append(other._data as Data)
    }
}

x.append(x)
y
//#-end-editable-code

/*:
Because we're only modifying the object `_data` is referring to, we don't even
have to mark `append` as `mutating`. After all, the reference stays constant,
and the struct too. Therefore, we were able to declare `x` and `y` using `let`,
even though they were mutable.

*/

