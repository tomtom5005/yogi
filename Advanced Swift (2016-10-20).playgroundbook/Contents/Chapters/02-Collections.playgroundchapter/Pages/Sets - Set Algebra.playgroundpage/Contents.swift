/*:
### Set Algebra

As the name implies, `Set` is closely related to the mathematical concept of a
set; it supports all common set operations you learned in math class. For
example, we can *subtract* one set from another:

*/

//#-editable-code
let iPods: Set = ["iPod touch", "iPod nano", "iPod mini", 
    "iPod shuffle", "iPod Classic"]
let discontinuedIPods: Set = ["iPod mini", "iPod Classic"]
let currentIPods = iPods.subtracting(discontinuedIPods)
//#-end-editable-code

/*:
We can also form the *intersection* of two sets, i.e. find all elements that are
in both:

*/

//#-editable-code
let touchscreen: Set = ["iPhone", "iPad", "iPod touch", "iPod nano"]
let iPodsWithTouch = iPods.intersection(touchscreen)
//#-end-editable-code

/*:
Or, we can form the *union* of two sets, i.e. combine them into one (removing
duplicates, of course):

*/

//#-editable-code
var discontinued: Set = ["iBook", "Powerbook", "Power Mac"]
discontinued.formUnion(discontinuedIPods)
discontinued
//#-end-editable-code

/*:
Here, we used the mutating variant `formUnion` to mutate the original set
(which, as a result, must be declared with `var`). Almost all set operations
have both non-mutating and mutating forms, the latter beginning with `form...`.
For even more set operations, check out the `SetAlgebra` protocol.

*/

