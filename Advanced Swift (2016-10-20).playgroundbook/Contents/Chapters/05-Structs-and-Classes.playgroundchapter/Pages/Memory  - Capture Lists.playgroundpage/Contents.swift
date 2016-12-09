/*:
### Capture Lists

*/

//#-hidden-code
class View {
    var window: Window
    init(window: Window) {
        self.window = window
    }
    deinit {
        print("Deinit View")
    }
}

class Window {
    weak var rootView: View?
    deinit {
        print("Deinit Window")
    }

    var onRotate: (() -> ())?
}
//#-end-hidden-code

//#-hidden-code
var window: Window? = Window()
var view: View? = View(window: window!)
window?.rootView = view!
//#-end-hidden-code

/*:
To break the cycle above, we want to make sure the closure won't reference the
view. We can do this by using a *capture list* and marking the captured variable
(`view`) as either `weak` or `unowned`:

*/

//#-editable-code
window?.onRotate = { [weak view] in
    print("We now also need to update the view: \(view)")
}
//#-end-editable-code

/*:
Capture lists can also be used to initialize new variables. For example, if we
wanted to have a weak variable that refers to the window, we could initialize it
in the capture list, or we could even define completely unrelated variables,
like so:

*/

//#-editable-code
window?.onRotate = { [weak view, weak myWindow=window, x=5*5] in
    print("We now also need to update the view: \(view)")
    print("Because the window \(myWindow) changed")
}
//#-end-editable-code

/*:
This is almost the same as defining the variable just above the closure, except
that with capture lists, the scope of the variable is just the scope of the
closure; it's not available outside of the closure.

*/
