/*:
## Copy-On-Write

In the Swift standard library, collections like `Array`, `Dictionary`, and `Set`
are implemented using a technique called *copy-on-write*. Let's say we have an
array of integers:

*/

//#-editable-code
var x = [1,2,3]
var y = x
//#-end-editable-code

/*:
If we create a new variable, `y`, and assign the value of `x` to it, a copy gets
made, and both `x` and `y` now contain independent structs. Internally, each of
these `Array` structs contains a reference to some memory. This memory is where
the elements of the array are stored, and it's located on the heap. At this
point, the references of both arrays point to the same location in memory — the
arrays are sharing this part of their storage. However, the moment we mutate
`x`, the shared reference gets detected, and the memory is copied. This means we
can mutate both variables independently, yet the (expensive) copy of the
elements only happens when it has to — once we mutate one of the variables:

*/

//#-editable-code
x.append(5)
y.removeLast()
x
y
//#-end-editable-code

/*:
If the reference inside the `Array` struct had been unique at the instant the
array was mutated (for example, by not declaring `y`), then no copy would've
been made; the memory would've been mutated in place. This behavior is called
*copy-on-write*, and as the author of a struct, it's not something you get for
free; you have to implement it yourself. Implementing copy-on-write behavior for
your own types makes sense whenever you define a struct that contains one or
more mutable references internally but should still retain value semantics, and
at the same time, avoid unnecessary copying.

*/
