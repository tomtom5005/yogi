/*:
### Functions Instead of Delegates

If the delegate protocol only has a single method defined, we can simply replace
the delegate property with a property that stores the callback function
directly. In our case, this could be an optional `buttonTapped` property, which
is `nil` by default. Unfortunately, we can't specify an argument label for the
button index:

*/

//#-editable-code
class AlertView {
    var buttons: [String]
    var buttonTapped: ((Int) -> ())?
    
    init(buttons: [String] = ["OK", "Cancel"]) {
        self.buttons = buttons
    }
    
    func fire() {
        buttonTapped?(1)
    }
}
//#-end-editable-code

/*:
Just like before, we can create a logger struct and then create an alert view
instance and a logger variable:

*/

//#-editable-code
struct TapLogger {
    var taps: [Int] = []
    
    mutating func logTap(index: Int) {
        taps.append(index)
    }
}

let av = AlertView()
var logger = TapLogger()
//#-end-editable-code

/*:
However, we can't simply assign the `logTap` method to the `buttonTapped`
property. The Swift compiler tells us that "partial application of a 'mutating'
method is not allowed":

``` swift-example
av.buttonTapped = logger.logTap // Error
```

In the code above, it's not clear what should happen in the assignment. Does the
`logger` get copied? Or should `buttonTapped` mutate the original variable (i.e.
`logger` gets captured)?

To make this work, we have to wrap the right-hand side of the assignment in a
closure. This has the benefit of making it very clear that we're now capturing
the original `logger` variable (not the value) and that we're mutating it:

*/

//#-editable-code
av.buttonTapped = { logger.logTap(index: $0) }
//#-end-editable-code

/*:
As an additional benefit, the naming is now decoupled: the callback property is
called `buttonTapped`, but the function that implements it is called `logTap`.
Rather than a method, we could also specify an anonymous function:

*/

//#-editable-code
av.buttonTapped = { print("Button \($0) was tapped") }
//#-end-editable-code

/*:
When working with classes and callbacks, there are some caveats. We create a
`Test` class that has a `buttonTapped` method:

*/

//#-editable-code
class Test {
    func buttonTapped(atIndex: Int) {
        print(atIndex)
    }
}

let test = Test()
//#-end-editable-code

/*:
We can assign the `buttonTapped` instance method of `Test` to our alert view:

*/

//#-editable-code
av.buttonTapped = test.buttonTapped
//#-end-editable-code

/*:
However, the alert view now has a strong reference to the `test` object (through
the closure). In the example above, there's no reference cycle, because `test`
doesn't reference the alert view. However, if we consider the view controller
example from before, we can see that it's very easy to create reference cycles
this way. To avoid a strong reference, it's often necessary to use a closure
with a capture list:

*/

//#-editable-code
av.buttonTapped = { [weak test] index in
    test?.buttonTapped(atIndex: index)
}
//#-end-editable-code

/*:
This way, the alert view doesn't have a strong reference to `test`. If the
object that `test` is referring to gets deinitialized before the closure gets
called, it'll be `nil` inside the closure, and the `buttonTapped` method won't
be called.

As we've seen, there are definite tradeoffs between protocols and callback
functions. A protocol adds some verbosity, but a class-only protocol with a weak
delegate removes the need to worry about introducing reference cycles.

Replacing the delegate with a function adds a lot of flexibility and allows you
to use structs and anonymous functions. However, when dealing with classes, you
need to be careful not to introduce a reference cycle.

Also, when you need multiple callback functions that are closely related (for
example, providing the data for a table view), it can be helpful to keep them
grouped together in a protocol rather than having individual callbacks. When
using a protocol, a single type has to implement all the methods.

To unregister a delegate or a function callback, we can simply set it to `nil`.
What about when our type stores an array of delegates or callbacks? With
class-based delegates, we can simply remove an object from the delegate list.
With callback functions, this isn't so simple; we'd need to add extra
infrastructure for unregistering, because functions can't be compared.

*/
