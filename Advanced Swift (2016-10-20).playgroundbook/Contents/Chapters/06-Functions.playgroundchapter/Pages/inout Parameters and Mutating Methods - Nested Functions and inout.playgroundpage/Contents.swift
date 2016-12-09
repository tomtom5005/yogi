/*:
### Nested Functions and `inout`

You can use an `inout` parameter with nested functions, but Swift will make sure
that your usage is safe. For example, you can define a nested function (either
using `func` or using a closure expression) and safely mutate an `inout`
parameter:

*/

//#-editable-code
func incrementTenTimes(value: inout Int) {
    func inc() {
        value += 1
    }
    for _ in 0..<10 {
        inc()
    }
}

var x = 0
incrementTenTimes(value: &x)
x
//#-end-editable-code

/*:
However, you're not allowed to let that `inout` parameter escape (we'll talk
more about escaping functions at the end of this chapter):

``` swift-example
func escapeIncrement(value: inout Int) -> () -> () {
    func inc() {
        value += 1
    }
    return inc
}
```

This makes sense, given that the `inout` value is copied back just before the
function returns. If we could somehow modify it later, what should happen?
Should the value get copied back at some point? What if the source no longer
exists? Having the compiler verify this is critical for safety.

*/
