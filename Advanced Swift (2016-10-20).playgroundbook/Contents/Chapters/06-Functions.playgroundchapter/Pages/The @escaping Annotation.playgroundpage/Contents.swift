/*:
## The `@escaping` Annotation

As we saw in the previous chapter, we need to be careful about memory when
dealing with functions. Recall the capture list example, where we needed to mark
`view` as `weak` in order to prevent a reference cycle:

``` swift-example
window?.onRotate = { [weak view] in
    print("We now also need to update the view: \(view)")
}
```

However, we never marked anything as `weak` when we used functions like `map`.
Since `map` is executed synchronously and the closure isn't referenced anywhere,
this isn't necessary, because no reference cycle will be created. The difference
between the closure we store in `onRotate` and the closure we pass to `map` is
that the first closure *escapes*.

A closure that's stored somewhere to be called later (for example, after a
function returns) is said to be *escaping*. The closure that gets passed to
`map` only gets used directly within `map`. This means that the compiler doesn't
need to change the reference count of the captured variables.

In Swift 3, closures are non-escaping by default. If you want to store a closure
for later use, you need to mark the closure argument as `@escaping`. The
compiler will verify this: unless you mark the closure argument as `@escaping`,
it won't allow you to store the closure (or return it to the caller, for
example). In the sort descriptors example, there were multiple function
parameters that required the `@escaping` attribute:

``` swift-example
func sortDescriptor<Value, Key>(
    key: @escaping (Value) -> Key,
    _ areInIncreasingOrder: @escaping (Key, Key) -> Bool)
    -> SortDescriptor<Value>
{
    return { areInIncreasingOrder(key($0), key($1)) }
}
```

> Before Swift 3, it was the other way around: you had the option to mark a
> closure as `@noescape`, and escaping was the default. The behavior in Swift 3
> is better because it's safe by default: a function argument now needs to be
> explicitly annotated to signal the potential for reference cycles. The
> `@escaping` annotation serves as a warning to the developer using the
> function. Non-escaping closures can also be optimized much better by the
> compiler, making the fast path the norm you have to explicitly deviate from if
> necessary.

Note that the non-escaping-by-default rule only applies to function types in
*immediate parameter position*. This means stored properties that have a
function type are always escaping (which makes sense). Surprisingly, the same is
true for closures that *are* used as parameters, but are wrapped in some other
type, such as a tuple or an optional. Since the closure is no longer an
*immediate* parameter in this case, it automatically becomes escaping. As a
consequence, you can't write a function that takes a function argument where the
parameter is both optional and non-escaping. In many situations, you can avoid
making the argument optional by prodiving a default value for the closure. If
that's not possible, a workaround is to use overloading to write two variants of
the function, one with an optional (escaping) function parameter and one with a
non-optional, non-escaping parameter:

*/

//#-editable-code
func transform(_ input: Int, with f: ((Int) -> Int)?) -> Int {
    print("Using optional overload")
    guard let f = f else { return input }
    return f(input)
}

func transform(_ input: Int, with f: (Int) -> Int) -> Int {
    print("Using non-optional overload")
    return f(input)
}
//#-end-editable-code

/*:
This way, calling the function with a `nil` argument (or a variable of optional
type) will use the optional variant, whereas passing a literal closure
expression will invoke the non-escaping, non-optional overload.

*/

//#-editable-code
transform(10, with: nil)
transform(10) { $0 * $0 }
//#-end-editable-code
