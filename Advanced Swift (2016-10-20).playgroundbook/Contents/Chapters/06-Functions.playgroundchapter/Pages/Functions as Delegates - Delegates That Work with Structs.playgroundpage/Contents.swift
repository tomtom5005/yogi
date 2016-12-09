/*:
### Delegates That Work with Structs

We can loosen the definition of `AlertViewDelegate` by not making it a
class-only protocol. Also, we'll mark the `buttonTapped(atIndex:)` method as
`mutating`. This way, a struct can mutate itself when the method gets called:

*/

//#-editable-code
protocol AlertViewDelegate {
    mutating func buttonTapped(atIndex: Int)
}
//#-end-editable-code

/*:
We also have to change our `AlertView` because the `delegate` property can no
longer be weak:

*/

//#-editable-code
class AlertView {
    var buttons: [String]
    var delegate: AlertViewDelegate?
    
    init(buttons: [String] = ["OK", "Cancel"]) {
        self.buttons = buttons
    }

    func fire() {
        delegate?.buttonTapped(atIndex: 1)
    }
}
//#-end-editable-code

/*:
If we assign an object to the `delegate` property, the object will be strongly
referenced. Especially when working with delegates, the strong reference means
there's a very high chance that we'll introduce a reference cycle at some point.
However, we can use structs now. For example, we could create a struct that logs
all button taps:

*/

//#-editable-code
struct TapLogger: AlertViewDelegate {
    var taps: [Int] = []
    mutating func buttonTapped(atIndex index: Int) {
        taps.append(index)
    }
}
//#-end-editable-code

/*:
At first, it might seem like everything works well. We can create an alert view
and a logger and connect the two. Alas, if we look at `logger.taps` after an
event is fired, the array is still empty:

*/

//#-editable-code
let av = AlertView()
var logger = TapLogger()
av.delegate = logger
av.fire()
logger.taps
//#-end-editable-code

/*:
When we assigned to `av.delegate`, we assigned a copy of the struct. So the
`taps` aren't recorded in `logger`, but rather in `av.delegate`. Even worse,
when we assign the value, we lose the information that it was a struct. To get
the information back out, we need a conditional type cast:

*/

//#-editable-code
if let theLogger = av.delegate as? TapLogger {
    print(theLogger.taps)
}
//#-end-editable-code

/*:
Clearly this approach doesn't work well. When using classes, it's easy to create
reference cycles, and when using structs, the original value doesn't get
mutated. In short: delegate protocols don't make much sense when using structs.

*/
