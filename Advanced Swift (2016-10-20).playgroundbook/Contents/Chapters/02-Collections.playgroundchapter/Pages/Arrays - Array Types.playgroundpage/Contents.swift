/*:
### Array Types

#### Slices

In addition to accessing a single element of an array by subscript (e.g.
`fibs[0]`), we can also access a range of elements by subscript. For example, to
get all but the first element of an array, we can do the following:

*/

//#-hidden-code
let fibs = [0, 1, 1, 2, 3, 5]
//#-end-hidden-code

//#-editable-code
let slice = fibs[1..<fibs.endIndex]
slice
type(of: slice)
//#-end-editable-code

/*:
This gets us a slice of the array starting at the second element, including the
last element. The type of the result is `ArraySlice`, not `Array`. `ArraySlice`
is a *view* on arrays. It's backed by the original array, yet it provides a view
on just the slice. This makes certain the array doesn't need to get copied. The
`ArraySlice` type has the same methods defined as `Array` does, so you can use
them as if they were arrays. If you do need to convert them into an array, you
can just construct a new array out of the slice:

*/

//#-editable-code
Array(fibs[1..<fibs.endIndex])
//#-end-editable-code

/*:
![Array Slices](artwork/arrayslice.png)

#### Bridging

Swift arrays can bridge to Objective-C. They can also be used with C, but we'll
cover that in a later chapter. Because `NSArray` can only hold objects, there
used to be a requirement that the elements of a Swift array had to be
convertible to `AnyObject` in order for it to be bridgeable. This constrained
the bridging to class instances and a small number of value types (such as
`Int`, `Bool`, and `String`) that supported automatic bridging to their
Objective-C counterparts.

This limitation no longer exists in Swift 3. The Objective-C `id` type [is now
imported into Swift as
`Any`](https://github.com/apple/swift-evolution/blob/master/proposals/0116-id-as-any.md)
instead of `AnyObject`, which means that any Swift array is now bridgeable to
`NSArray`. `NSArray` still always expects objects, of course, so the compiler
and runtime will automatically wrap incompatible values in an opaque box class
behind the scenes. Unwrapping in the reverse direction also happens
automatically.

> A universal bridging mechanism for all Swift types to Objective-C doesn't just
> make working with arrays more pleasant. It also applies to other collections,
> like dictionaries and sets, and it opens up a lot of potential for future
> enhancements to the interoperability between Swift and Objective-C. For
> example, now that Swift values can be bridged to Objective-C objects, a future
> Swift version could conceivably allow Swift value types to conform to `@objc`
> protocols.

*/
