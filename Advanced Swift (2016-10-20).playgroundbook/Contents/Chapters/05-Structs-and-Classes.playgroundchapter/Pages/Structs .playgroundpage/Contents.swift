/*:
## Structs 

Value types imply that whenever a variable is copied, the value itself — and not
just a reference to the value — is copied. For example, in almost all
programming languages, scalar types are value types. This means that whenever a
value is assigned to a new variable, it's copied rather than passed by
reference:

*/

//#-editable-code
var a = 42
var b = a
b += 1
b
a
//#-end-editable-code

/*:
After the above code executes, the value of `b` will be 43, but `a` will still
be 42. This is so natural that it seems like stating the obvious. However, in
Swift, all structs behave this way — not just scalar types.

Let's start with a simple struct that describes a `Point`. This is similar to
`CGPoint`, except that it contains `Int`s, whereas `CGPoint` contains
`CGFloat`s:

*/

//#-editable-code
struct Point {
    var x: Int
    var y: Int
}
//#-end-editable-code

//#-hidden-code
extension Point: CustomStringConvertible {
    var description: String {
        return "(x: \(x), y: \(y))"
    }
}
//#-end-hidden-code

/*:
For structs, Swift automatically adds a memberwise initializer. This means we
can now initialize a new variable:

*/

//#-editable-code
let origin = Point(x: 0, y: 0)
//#-end-editable-code

/*:
Because structs in Swift have value semantics, we can't change any of the
properties of a struct variable that's defined using `let`. For example, the
following code won't work:

``` swift-example
origin.x = 10 // Error
```

Even though we defined `x` within the struct as a `var` property, we can't
change it, because `origin` is defined using `let`. This has some major
advantages. For example, if you read a line like `let point = ...`, and you know
that `point` is a struct variable, then you also know that it'll never, ever,
change. This is a great help when reading through code.

To create a mutable variable, we need to use `var`:

*/

//#-editable-code
var otherPoint = Point(x: 0, y: 0)
otherPoint.x += 10
otherPoint
//#-end-editable-code

/*:
Unlike with objects, every struct variable is unique. For example, we can create
a new variable, `thirdPoint`, and assign the value of `origin` to it. Now we can
change `thirdPoint`, but `origin` (which we defined as an immutable variable
using `let`) won't change:

*/

//#-editable-code
var thirdPoint = origin
thirdPoint.x += 10
thirdPoint
origin
//#-end-editable-code

/*:
When you assign a struct to a new variable, Swift automatically makes a copy.
Even though this sounds very expensive, many of the copies can be optimized away
by the compiler, and Swift tries hard to make the copies very cheap. In fact,
many structs in the standard library are implemented using a technique called
copy-on-write, which we'll look at later.

If we have struct values that we plan to use more often, we can define them in
an extension as a static property. For example, we can define an `origin`
property on `Point` so that we can write `Point.origin` everywhere we need it:

*/

//#-editable-code
extension Point {
    static let origin = Point(x: 0, y: 0)
}
Point.origin
//#-end-editable-code

/*:
Structs can also contain other structs. For example, if we define a `Size`
struct, we can create a `Rect` struct, which is composed out of a point and a
size:

*/

//#-editable-code
struct Size {
    var width: Int
    var height: Int
}

struct Rectangle {
    var origin: Point
    var size: Size
}
//#-end-editable-code

//#-hidden-code
extension Rectangle: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\((origin.x, origin.y, size.width, size.height))"
    }
}
//#-end-hidden-code

/*:
Just like before, we get a memberwise initializer for `Rectangle`. The order of
the parameters matches the order of the property definitions:

*/

//#-editable-code
Rectangle(origin: Point.origin, 
    size: Size(width: 320, height: 480))
//#-end-editable-code

/*:
If we want a custom initializer for our struct, we can add it directly inside
the struct definition. However, if the struct definition contains a custom
initializer, Swift doesn't generate a memberwise initializer. By defining our
custom initializer in an extension, we also get to keep the memberwise
initializer:

*/

//#-editable-code
extension Rectangle {
    init(x: Int = 0, y: Int = 0, width: Int, height: Int) {
        origin = Point(x: x, y: y)
        size = Size(width: width, height: height)
    }
}
//#-end-editable-code

/*:
Instead of setting `origin` and `size` directly, we could've also called
`self.init(origin:size:)`.

If we define a mutable variable `screen`, we can add a `didSet` block that gets
executed whenever `screen` changes. This `didSet` works for every definition of
a struct, be it in a playground, in a class, or when defining a global variable:

*/

//#-editable-code
var screen = Rectangle(width: 320, height: 480) {
    didSet {
        print("Screen changed: \(screen)")
    }
}
//#-end-editable-code

/*:
Maybe somewhat surprisingly, even if we change something deep inside the struct,
the following will get triggered:

*/

//#-editable-code
screen.origin.x = 10
//#-end-editable-code

/*:
Understanding why this works is key to understanding value types. Mutating a
struct variable is semantically the same as assigning a new value to it. When we
mutate something deep inside the struct, it still means we're mutating the
struct, so `didSet` still needs to get triggered.

Although we semantically replace the entire struct with a new one, the compiler
can still mutate the value in place; since the struct has no other owner, it
doesn't actually need to make a copy. With copy-on-write structs (which we'll
discuss later), this works differently.

Since arrays are structs, this naturally works with them, too. If we define an
array containing other value types, we can modify one of the properties of an
element in the array and still get a `didSet` trigger:

*/

//#-editable-code
var screens = [Rectangle(width: 320, height: 480)] {
    didSet {
        print("Array changed")
    }
}
screens[0].origin.x += 100
//#-end-editable-code

/*:
The `didSet` trigger wouldn't fire if `Rectangle` were a class, because in that
case, the reference the array stores doesn't change — only the object it's
referring to does.

To add two `Points` together, we can write an overload for the `+` operator.
Inside, we add both members and return a new `Point`:

*/

//#-editable-code
func +(lhs: Point, rhs: Point) -> Point {
    return Point(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}
screen.origin + Point(x: 10, y: 10)
//#-end-editable-code

/*:
We can also make this operation work on rectangles and add a `translate` method,
which moves the rectangle by a given offset. Our first attempt doesn't work:

``` swift-example
extension Rectangle {
    func translate(by offset: Point) {
        // Error: Cannot assign to property: 'self' is immutable
        origin = origin + offset
    }
}
```

The compiler tells us that we can't assign to the `origin` property because
`self` is immutable (writing `origin =` is shorthand for `self.origin =`). We
can think of `self` as an extra, implicit parameter that gets passed to every
method on `Rectangle`. You never have to pass the parameter, but it's always
there inside the method body, and it's immutable so that value semantics can be
guaranteed. If we want to mutate `self`, or any property of `self`, or even
nested properties (e.g. `self.origin.x`), we need to mark our method as
`mutating`:

*/

//#-editable-code
extension Rectangle {
    mutating func translate(by offset: Point) {
        origin = origin + offset
    }
}
screen.translate(by: Point(x: 10, y: 10))
screen
//#-end-editable-code

/*:
The compiler enforces the `mutating` keyword. Unless we use it, we're not
allowed to mutate anything inside the method. By marking the method as
`mutating`, we change the behavior of `self`. Instead of it being a `let`, it
now works like a `var`: we can freely change any property. (To be precise, it's
not even a `var`, but we'll get to that in a little bit).

If we define a `Rectangle` variable using `let`, we can't call `translate` on
it, because the only `Rectangle`s that are mutable are the ones defined using
`var`:

``` swift-example
let otherScreen = screen
// Error: Cannot use mutating member on immutable value
otherScreen.translate(by: Point(x: 10, y: 10))
```

Thinking back to the built-in collections chapter, we can now see how the
difference between `let` and `var` applies to collections as well. The `append`
method on arrays is defined as `mutating`, and therefore, we're not allowed to
call it on an array declared with `let`.

Swift automatically marks property setters as `mutating`; you can't call a
setter on a `let` variable. The same is true for subscript setters:

``` swift-example
let point = Point.origin
// Error: Cannot assign to property: 'point' is a 'let' constant
point.x = 10 
```

In many cases, it makes sense to have both a mutable and an immutable variant of
the same method. For example, arrays have both a `sort()` method (which is
`mutating` and sorts in place) and a `sorted()` method (which returns a new
array). We can also add a non-`mutating` variant of our `translate(by:_)`
method. Instead of mutating `self`, we create a copy, mutate that, and return a
new `Rectangle`:

*/

//#-editable-code
extension Rectangle {
    func translated(by offset: Point) -> Rectangle {
        var copy = self
        copy.translate(by: offset)
        return copy
    }
}
screen.translated(by: Point(x: 20, y: 20))
//#-end-editable-code

/*:
> The names `sort` and `sorted` aren't chosen at random; rather, they're names
> that conform to the Swift [API Design
> Guidelines](https://swift.org/documentation/api-design-guidelines/). We
> applied the same guidelines to `translate` and `translated`. There's even
> specific documentation for methods that have a mutating and a non-mutating
> variant: because `translate` has a side effect, it should read as an
> imperative verb phrase. The non-mutating variant should have an -ed or -ing
> suffix.

As we saw in the introduction of this chapter, when dealing with mutating code,
it's easy to introduce bugs: because the object you're just checking can be
modified from a different thread (or even a different method on the same
thread), your assumptions might be invalid.

Swift structs with `mutating` methods and properties don't have the same
problems. The mutation of the struct is a local side effect, and it only applies
to the current struct variable. Because every struct variable is unique (or in
other words: every struct value has exactly one owner), it's almost impossible
to introduce bugs this way. That is, unless you're referring to a global struct
variable across threads.

To understand how the `mutating` keyword works, we can look at the behavior of
`inout`. In Swift, we can mark function parameters as `inout`. Before we do
that, let's define a free function that moves a rectangle by 10 points on both
axes. We can't simply call `translate` directly on the `rectangle` parameter,
because all function parameters are immutable by default and get passed in as
copies. Instead, we need to use `translated(by:)`. Then we need to re-assign the
result of the function to `screen`:

*/

//#-editable-code
func translatedByTenTen(rectangle: Rectangle) -> Rectangle {
    return rectangle.translated(by: Point(x: 10, y: 10))
}
screen = translatedByTenTen(rectangle: screen)
screen
//#-end-editable-code

/*:
How could we write a function that changes the `rectangle` in place? Looking
back, the `mutating` keyword does exactly that. It makes the implicit `self`
parameter mutable, and it changes the value of the variable.

In functions, we can mark parameters as `inout`. Just like with a regular
parameter, a copy of the value gets passed in to the function. However, we can
change the copy (it's as if it were defined as a `var`). And once the function
returns, the original value gets overwritten. Now we can use `translate(by:)`
instead of `translated(by:)`:

*/

//#-editable-code
func translateByTwentyTwenty(rectangle: inout Rectangle) {
    rectangle.translate(by: Point(x: 20, y: 20))
}
translateByTwentyTwenty(rectangle: &screen)
screen
//#-end-editable-code

/*:
The `translateByTwentyTwenty` function takes the `screen` rectangle, changes it
locally, and copies the new value back (overriding the previous value of
`screen`). This behavior is exactly the same as that of a `mutating` method. In
fact, `mutating` methods are just like regular methods on the struct, except the
implicit `self` parameter is marked as `inout`.

We can't call `translateByTwentyTwenty` on a rectangle that's defined using
`let`. We can only use it with mutable values:

``` swift-example
let immutableScreen = screen
// Error: Cannot pass immutable value as inout argument
translateByTwentyTwenty(rectangle: &immutableScreen)
```

Now it also makes sense how we had to write a mutating operator like `+=`. Such
operators modify the left-hand side, so that parameter must be `inout`:

*/

//#-editable-code
func +=(lhs: inout Point, rhs: Point) {
    lhs = lhs + rhs
}
var myPoint = Point.origin
myPoint += Point(x: 10, y: 10)
myPoint
//#-end-editable-code

/*:
In the functions chapter, we'll go into more detail about `inout`. For now, it
suffices to say that `inout` is in lots of places. For example, it's now easy to
understand how mutating a value through a subscript works:

*/

//#-editable-code
var array = [Point(x: 0, y: 0), Point(x: 10, y: 10)]
array[0] += Point(x: 100, y: 100)
array
//#-end-editable-code

/*:
The expression `array[0]` is automatically passed in as an `inout` variable. In
the functions chapter, we'll see why we can use expressions like `array[0]` as
an `inout` parameter.

Let's revisit the `BinaryScanner` example from the introduction of this chapter.
We had the following problematic code snippet:

``` swift-example
for _ in 0..<Int.max {
    let newScanner = BinaryScanner(data: "hi".data(using: .utf8)!)
    DispatchQueue.global().async {
        scanRemainingBytes(scanner: newScanner)
    }
    scanRemainingBytes(scanner: newScanner)
}
```

If we make `BinaryScanner` a struct instead of a class, each call to
`scanRemainingBytes` gets its own independent copy of `newScanner`. Therefore,
the calls can safely keep iterating over the array without having to worry that
the struct gets mutated from a different method or thread.

Structs don't magically make your code safe for multithreading. For example, if
we keep `BinaryScanner` as a struct but inline the `scanRemainingBytes` method,
we end up with the same race condition as we had before. Both the `while` loop
inside the closure, as well as the `while` loop outside of the closure, refer to
the same `newScanner` variable, and both will mutate it at the same time:

``` swift-example
for _ in 0..<Int.max {
    let newScanner = BinaryScanner(data: "hi".data(using: .utf8)!)
    DispatchQueue.global().async {
        while let byte = newScanner.scanByte() {
          print(byte)
        }
    }
    while let byte = newScanner.scanByte() {
      print(byte)
    }
}
```

*/
