/*:
### Weak References

To break the reference cycle, we need to make sure that one of the references is
either `weak` or `unowned`. When you mark a variable as `weak`, assigning a
value to it doesn't change the reference count. A weak reference also means that
the reference will be `nil` once the referred object gets deallocated. For
example, we could make the `rootView` property `weak`, which means it won't be
strongly referenced by the window and automatically becomes `nil` once the view
is deallocated. When you're dealing with a weak variable, you have to make it
optional. To debug the memory behavior, we can add a deinitializer, which gets
called just before the class deallocates:

*/

//#-editable-code
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
}
//#-end-editable-code

/*:
In the code below, we create a window and a view. The view strongly references
the window, but because the window's `rootView` is declared as `weak`, the
window doesn't strongly reference the view. This way, we have no reference
cycle, and after setting both variables to `nil`, both views get deallocated:

*/

//#-editable-code
var window: Window? = Window()
var view: View? = View(window: window!)
window?.rootView = view!
window = nil
view = nil
//#-end-editable-code

/*:
A weak reference is very useful when working with delegates. The object that
calls the delegate methods shouldn't own the delegate. Therefore, a delegate is
usually marked as `weak`, and another object is responsible for making sure the
delegate stays around for as long as needed.

*/
