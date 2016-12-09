/*:
To make `addCircle` dynamically dispatched, we add it as a protocol requirement:

*/

//#-hidden-code
#if os(macOS)
import Cocoa
typealias UIColor = NSColor
#else
import UIKit
#endif
//#-end-hidden-code

//#-editable-code
protocol Drawing {
    mutating func addEllipse(rect: CGRect, fill: UIColor)
    mutating func addRectangle(rect: CGRect, fill: UIColor)
    mutating func addCircle(center: CGPoint, radius: CGFloat, fill: UIColor)
}
//#-end-editable-code

/*:
We can still provide a default implementation, just like before:

*/

//#-hidden-code
extension Drawing {
    mutating func addCircle(center: CGPoint, radius: CGFloat, fill: UIColor) {
        let diameter = radius/2
        let origin = CGPoint(x: center.x - diameter, y: center.y - diameter)
        let size = CGSize(width: radius, height: radius)
        let rect = CGRect(origin: origin, size: size)
        addEllipse(rect: rect, fill: fill)
    }
}
//#-end-hidden-code

/*:
And also like before, types are free to override `addCircle`. Because it's now
part of the protocol definition, it'll be dynamically dispatched — at runtime,
depending on the dynamic type of the receiver, the existential container will
call the custom implementation if one exists. If it doesn't exist, it'll use the
default implementation from the protocol extension. The `addCircle` method has
become a *customization point* for the protocol.

The Swift standard library uses this technique a lot. A protocol like `Sequence`
has dozens of requirements, yet almost all have default implementations. A
conforming type can customize the default implementations because the methods
are dynamically dispatched, but it doesn't have to.

*/
