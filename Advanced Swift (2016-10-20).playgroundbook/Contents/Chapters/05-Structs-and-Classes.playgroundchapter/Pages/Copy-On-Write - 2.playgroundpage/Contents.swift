/*:
To see how this works, we'll reimplement the `Data` struct from Foundation and
use the `NSMutableData` class as our internal reference type. `Data` is a value
type, and it behaves just like you'd expect:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
var input: [UInt8] = [0x0b,0xad,0xf0,0x0d]
var other: [UInt8] = [0x0d]
var d = Data(bytes: input)
var e = d
d.append(contentsOf: other)
d
e
//#-end-editable-code

/*:
As we can see above, `d` and `e` are independent: adding a byte to `d` doesn't
change the value of `e`.

Writing the same example using `NSMutableData`, we can see that objects are
shared:

*/

//#-editable-code
var f = NSMutableData(bytes: &input, length: input.count)
var g = f
f.append(&other, length: other.count)
f
g
//#-end-editable-code

/*:
Both `f` and `g` refer to the same object (in other words: they point to the
same piece of memory), so changing one also changes the other. We can even
verify that they refer to the same object by using the `===` operator:

*/

//#-editable-code
f===g
//#-end-editable-code

