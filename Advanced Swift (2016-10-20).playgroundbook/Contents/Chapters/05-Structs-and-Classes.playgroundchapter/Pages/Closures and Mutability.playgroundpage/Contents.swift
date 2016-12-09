/*:
## Closures and Mutability

In this section, we'll look at how closures store data.

For example, consider a function that generates a unique integer every time it
gets called (until it reaches `Int.max`). It works by moving the state outside
of the function. In other words, it *closes* over the variable `i`:

*/

//#-editable-code
var i = 0
func uniqueInteger() -> Int {
    i += 1
    return i
}
//#-end-editable-code

/*:
Every time we call this function, the shared variable `i` will change, and a
different integer will be returned. Functions are reference types as well — if
we assign `uniqueInteger` to another variable, the compiler won't copy the
function (or `i`). Instead, it'll create a reference to the same function:

*/

//#-editable-code
let otherFunction: () -> Int = uniqueInteger
//#-end-editable-code

/*:
Calling `otherFunction` will have exactly the same effect as calling
`uniqueInteger`. This is true for all closures and functions: if we pass them
around, they always get passed by reference, and they always share the same
state.

Recall the function-based `fibsIterator` example from the collection protocols
chapter, where we saw this behavior before. When we used the iterator, the
iterator itself (being a function) was mutating its state. In order to create a
fresh iterator for each iteration, we had to wrap it in an `AnySequence`.

If we want to have multiple different unique integer providers, we can use the
same technique: instead of returning the integer, we return a closure that
captures the mutable variable. The returned closure is a reference type, and
passing it around will share the state. However, calling `uniqueIntegerProvider`
repeatedly returns a fresh function that starts at zero every time:

*/

//#-editable-code
func uniqueIntegerProvider() -> () -> Int {
    var i = 0
    return { 
        i += 1
        return i
    }
}
//#-end-editable-code

/*:
Instead of returning a closure, we can also wrap the behavior in an
`AnyIterator`. That way, we can even use our integer provider in a for loop:

*/

//#-editable-code
func uniqueIntegerProvider() -> AnyIterator<Int> {
    var i = 0
    return AnyIterator {
        i += 1
        return i
    }
}
//#-end-editable-code

/*:
Swift structs are commonly stored on the stack rather than on the heap. However,
this is an optimization: by default, a struct is stored on the heap, and in
almost all cases, the optimization will store the struct on the stack. When a
struct variable is closed over by a function, the optimization doesn't apply,
and the struct is stored on the heap. Because the `i` variable is closed over by
the function, the struct exists on the heap. That way, it persists even when the
scope of `uniqueIntegerProvider` exits. Likewise, if a struct is too large, it's
also stored on the heap.

*/
