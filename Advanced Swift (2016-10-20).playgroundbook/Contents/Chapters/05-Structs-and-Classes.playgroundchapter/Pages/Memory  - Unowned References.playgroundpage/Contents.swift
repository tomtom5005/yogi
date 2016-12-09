/*:
### Unowned References

Weak references must always be optional types because they can become `nil`, but
sometimes we may not want this. For example, maybe we know that our views will
always have a window (so the property shouldn't be optional), but we don't want
a view to strongly reference the window. In other words, assigning to property
should leave the reference count unchanged. For these cases, there's the
`unowned` keyword, which assumes the reference is always valid:

*/

//#-editable-code
class View {
    unowned var window: Window
    init(window: Window) {
        self.window = window
    }
    deinit {
        print("Deinit View")
    }
}

class Window {
    var rootView: View?
    deinit {
        print("Deinit Window")
    }
}
//#-end-editable-code

/*:
Now we can create a window, create views, and set the window's root view.
There's no reference cycle, but we're responsible for ensuring that the window
outlives the view. If the window is deallocated and the unowned variable is
accessed, there'll be a runtime crash. In the code below, we can see that both
objects get deallocated:

*/

//#-editable-code
var window: Window? = Window()
var view: View? = View(window: window!)
window?.rootView = view
view = nil
window = nil
//#-end-editable-code

/*:
The Swift runtime keeps a second reference count in the object to keep track of
unowned references. When all strong references are gone, the object will release
all of its resources (for example, any references to other objects). However,
the memory of the object itself will still be there until all unowned references
are gone too. The memory is marked as invalid (sometimes also called *zombie*
memory), and any time we try to access an unowned reference, a runtime error
will occur.

Note that this isn't the same as undefined behavior. There's a third option,
`unowned(unsafe)`, which doesn't have this runtime check. If we access an
invalid reference that's marked as `unowned(unsafe)`, we get undefined behavior.

When you don't need `weak`, [it's
recommended](https://twitter.com/jckarter/status/654819932962598913) that you
use `unowned`. A `weak` variable always needs to be defined using `var`, whereas
an `unowned` variable can be defined using `let` and be immutable. However, only
use `unowned` in situations where you know that the reference will always be
valid.

Personally, we often find ourselves using `weak`, even when `unowned` could be
used. We might want to refactor some code at a later point, and our assumptions
about the lifetime of an object might not be valid anymore. When using `weak`,
the compiler forces us to deal with the possibility that a reference might
become `nil`.

*/
