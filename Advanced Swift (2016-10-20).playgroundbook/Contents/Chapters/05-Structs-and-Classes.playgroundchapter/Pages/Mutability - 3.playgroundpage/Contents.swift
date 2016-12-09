/*:
Classes are reference types. If you create an instance of a class and assign it
to a new variable, both variables point to the same object:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
let mutableArray: NSMutableArray = [1, 2, 3]
let otherArray = mutableArray
mutableArray.add(4)
otherArray
//#-end-editable-code

/*:
Because both variables refer to the same object, they now both refer to the
array `[1, 2, 3, 4]`, since changing the value of one variable also changes the
value of the other variable. This is a very powerful thing, but it's also a
great source of bugs. Calling a method might change something you didn't expect
to change, and your invariant won't hold anymore.

*/
