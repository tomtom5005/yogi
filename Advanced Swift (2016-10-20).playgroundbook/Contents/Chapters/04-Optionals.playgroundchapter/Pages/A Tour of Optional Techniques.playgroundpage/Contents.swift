/*:
## A Tour of Optional Techniques

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-hidden-code
import UIKit
import PlaygroundSupport
//#-end-hidden-code

/*:
Optionals have a lot of extra support built into the language. Some of the
examples below might look very simple if you've been writing Swift, but it's
important to make sure you know all of these concepts well, as we'll be using
them again and again throughout the book.

### `if let`

Optional binding with `if let` is just a short step away from the `switch`
statement above:

*/

//#-editable-code
var array = ["one", "two", "three", "four"]
if let idx = array.index(of: "four") {
    array.remove(at: idx)
}
//#-end-editable-code

/*:
An optional binding with `if` can have boolean clauses as well. So suppose you
didn't want to remove the element if it happened to be the first one in the
array:

*/

//#-editable-code
if let idx = array.index(of: "four"), idx != array.startIndex {
    array.remove(at: idx)
}
//#-end-editable-code

/*:
You can also bind multiple entries in the same `if` statement. What's more is
that later entries can rely on the earlier ones being successfully unwrapped.
This is very useful when you want to make multiple calls to functions that
return optionals themselves. For example, these `URL` and `UIImage` initializers
are all "failable" — that is, they can return `nil` — if your URL is malformed,
or if the data isn't an image. The `Data` initializer can throw an error, and by
using `try?`, we can convert it into an optional as well. All three can be
chained together, like this:

*/

let urlString = "http://www.objc.io/logo.png"
if let url = URL(string: urlString),
    let data = try? Data(contentsOf: url),
    let image = UIImage(data: data)
{
    let view = UIImageView(image: image)
    PlaygroundPage.current.liveView = view
}

/*:
Separate parts of a multi-variable `let` can have a boolean clause as well:

*/

if let url = URL(string: urlString), url.pathExtension == "png",
    let data = try? Data(contentsOf: url),
    let image = UIImage(data: data)
{
    let view = UIImageView(image: image)
}

/*:
If you need to perform a check *before* performing various `if let` bindings,
you can supply a leading boolean condition. Suppose you're using a storyboard
and want to check the segue identifier before casting to a specific kind of view
controller:

*/

//#-hidden-code
let segue = UIStoryboardSegue(identifier: nil, source: UIViewController(), destination: UIViewController())

class UserDetailViewController: UIViewController {
    var screenName: String? = ""
}
//#-end-hidden-code

if segue.identifier == "showUserDetailsSegue",
    let userDetailVC = segue.destination
    as? UserDetailViewController
{
    userDetailVC.screenName = "Hello"
}

/*:
You can also mix and match optional bindings, boolean clauses, and `case let`
bindings within the same `if` statement.

`if let` binding can also help with Foundation's `Scanner` type, which returns a
boolean value to indicate whether or not it successfully scanned something,
after which you can unwrap the result:

*/

//#-editable-code
let scanner = Scanner(string: "myUserName123")
var username: NSString?
let alphas = CharacterSet.alphanumerics

if scanner.scanCharacters(from: alphas, into: &username),
    let name = username {
    print(name)
}
//#-end-editable-code
