/*:
### Delegates, Foundation-Style

Let's start off by defining a delegate protocol in the same way that Foundation
defines its protocols. Most programmers who come from Objective-C have written
code like this many times over:

*/

//#-editable-code
protocol AlertViewDelegate: class {
    func buttonTapped(atIndex: Int)
}
//#-end-editable-code

/*:
It's defined as a class-only protocol, because in our `AlertView` class, we want
to have a weak reference to the delegate. This way, we don't have to worry about
reference cycles. An `AlertView` will never strongly retain its delegate, so
even if the delegate strongly retains the alert view, all is well. If the
delegate is deinitialized, the `delegate` property will automatically become
`nil`:

*/

//#-editable-code
class AlertView {
    var buttons: [String]
    weak var delegate: AlertViewDelegate?
    
    init(buttons: [String] = ["OK", "Cancel"]) {
        self.buttons = buttons
    }

    func fire() {
        delegate?.buttonTapped(atIndex: 1)
    }
}
//#-end-editable-code

/*:
This pattern works really well when we're dealing with classes. For example, we
could create a `ViewController` class that initializes the alert view and sets
itself as the delegate. Because the delegate is marked as `weak`, we don't need
to worry about reference cycles:

*/

//#-editable-code
class ViewController: AlertViewDelegate {
    init() {
        let av = AlertView(buttons: ["OK", "Cancel"])
        av.delegate = self
    }
    
    func buttonTapped(atIndex index: Int) {
        print("Button tapped: \(index)")
    }
}
//#-end-editable-code

/*:
It's common practice to always mark delegates as `weak`. This makes it very easy
to reason about the memory management. Classes that implement the delegate
protocol don't have to worry about creating a reference cycle.

Sometimes we might want to have a delegate protocol that's implemented by a
struct. With the current definition of `AlertViewDelegate`, this is impossible,
because it's a class-only protocol.

*/
