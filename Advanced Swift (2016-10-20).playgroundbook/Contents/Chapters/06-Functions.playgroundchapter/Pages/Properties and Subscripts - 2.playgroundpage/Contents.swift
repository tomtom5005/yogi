/*:
If we want to make the `record` property available as read-only to the outside,
but read-write internally, we can use the `private(set)` or `fileprivate(set)`
modifiers:

*/

//#-hidden-code
import Foundation
import CoreLocation
//#-end-hidden-code

struct GPSTrack {
    private(set) var record: [(CLLocation, Date)] = []
}

/*:
To access all the dates in a GPS track, we create a computed property:

*/

extension GPSTrack {
    /// Returns all the dates for the GPS track.
    /// - Complexity: O(*n*), where *n* is the number of points recorded.
    var dates: [Date] {
        return record.map { $0.1 }
    }
}

/*:
Because we didn't specify a setter, the `dates` property is read-only. The
result isn't cached; each time you access the `dates` property, it computes the
result. The Swift API Design Guidelines recommend that you document the
complexity of every computed property that isn't `O(1)`, because callers might
assume that computing a property takes constant time.

### Lazy Stored Properties

Initializing a value lazily is such a common pattern that Swift has a special
`lazy` keyword to define a lazy property. Note that a lazy property is
automatically `mutating` and therefore must be declared as `var`. The lazy
modifier is a very specific form of
[memoization](https://en.wikipedia.org/wiki/Memoization).

For example, if we have a view controller that displays a `GPSTrack`, we might
want to have a preview image of the track. By making the property for that lazy,
we can defer the expensive generation of the image until the property is
accessed for the first time:

*/

//#-hidden-code
import UIKit
//#-end-hidden-code

class GPSTrackViewController: UIViewController {
    var track: GPSTrack = GPSTrack()

    lazy var preview: UIImage = {
        for point in self.track.record {
            // Do some expensive computation
        }
        return UIImage()
    }()
}

/*:
Notice how we defined the lazy property: it's a closure expression that returns
the value we want to store — in our case, an image. When the property is first
accessed, the closure is executed (note the parentheses at the end), and its
return value is stored in the property. This is a common pattern for lazy
properties that require more than a one-liner to be initialized.

Because a lazy variable needs storage, we're required to define the lazy
property in the definition of `GPSTrackViewController`. Unlike computed
properties, stored properties and stored lazy properties can't be defined in an
extension. Also, we're required to use `self.` inside the closure expression
when we want to access instance members (in this case, we need to write
`self.track`).

If the `track` property changes, the `preview` won't automatically get
invalidated. Let's look at an even simpler example to see what's going on. We
have a `Point` struct, and we store `distanceFromOrigin` as a lazy computed
property:

*/

//#-editable-code
struct Point {
    var x: Double = 0
    var y: Double = 0
    lazy var distanceFromOrigin: Double = self.x*self.x + self.y*self.y

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}
//#-end-editable-code

/*:
When we create a point, we can access the `distanceFromOrigin` property, and
it'll compute the value and store it for reuse. However, if we then change the
`x` value, this won't be reflected in `distanceFromOrigin`:

*/

//#-editable-code
var point = Point(x: 3, y: 4)
point.distanceFromOrigin
point.x += 10
point.distanceFromOrigin
//#-end-editable-code

/*:
It's important to be aware of this. One way around it would be to recompute
`distanceFromOrigin` in the `didSet` property observers of `x` and `y`, but then
`distanceFromOrigin` isn't really lazy anymore: it'll get computed each time `x`
or `y` changes. Of course, in this example, the solution is easy: we should have
made `distanceFromOrigin` a regular (non-lazy) computed property from the
beginning.

As we saw in the chapter on structs and classes, we can also implement the
`willSet` and `didSet` callbacks for properties and variables. These get called
before and after the setter, respectively. One useful case is when working with
Interface Builder: we can implement `didSet` to know when an `IBOutlet` gets
connected, and then we can configure our views there. For example, if we want to
set a label's text color once it's available, we can do the following:

*/

class SettingsController: UIViewController {
    @IBOutlet weak var label: UILabel? {
        didSet {
            label?.textColor = .black
        }
    }
}
