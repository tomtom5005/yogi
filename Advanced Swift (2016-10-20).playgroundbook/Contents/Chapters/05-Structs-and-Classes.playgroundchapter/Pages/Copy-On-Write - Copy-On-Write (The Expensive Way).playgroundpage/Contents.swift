/*:
### Copy-On-Write (The Expensive Way)

To implement copy-on-write, we can make `_data` a private property of the
struct. Instead of mutating `_data` directly, we access it through a computed
property, `_dataForWriting`. This computed property always makes a copy and
returns it:

*/

//#-hidden-code
import Foundation

//#-end-hidden-code

//#-editable-code
struct MyData {
    fileprivate var _data: NSMutableData
    var _dataForWriting: NSMutableData {
        mutating get {
            _data = _data.mutableCopy() as! NSMutableData
            return _data
        }
    }
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
Because `_dataForWriting` mutates the struct (it assigns a new value to the
`_data` property), the getter has to be marked as `mutating`. This means we can
only use it on variables declared with `var`.

We can use `_dataForWriting` in our `append` method, which now also needs to be
marked as `mutating`:

*/

//#-editable-code
extension MyData {
    mutating func append(_ other: MyData) {
        _dataForWriting.append(other._data as Data)
    }
}
//#-end-editable-code

/*:
Our struct now has value semantics. If we assign the value of `x` to the
variable `y`, both variables are still pointing to the same underlying
`NSMutableData` object. However, the moment we use `append` on either one of the
variables, a copy gets made:

*/

//#-editable-code
let theData = NSData(base64Encoded: "wAEP/w==", options: [])!
var x = MyData(theData)
let y = x
x._data===y._data
x.append(x)
y
x._data===y._data
//#-end-editable-code

/*:
This strategy works, but it's not very efficient if we mutate the same variable
multiple times. For example, consider the following example:

*/

//#-editable-code
var buffer = MyData(NSData())
for _ in 0..<5 {
    buffer.append(x)
}
//#-end-editable-code

/*:
Each time we call `append`, the underlying `_data` object gets copied. Because
we're not sharing the `buffer` variable, it'd have been a lot more efficient to
mutate it in place.

*/

