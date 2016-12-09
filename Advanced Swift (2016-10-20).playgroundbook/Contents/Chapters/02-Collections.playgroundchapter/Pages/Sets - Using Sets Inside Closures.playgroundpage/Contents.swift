/*:
### Using Sets Inside Closures

Dictionaries and sets can be very handy data structures to use inside your
functions, even when you're not exposing them to the caller. For example, if we
want to write an extension on `Sequence` to retrieve all unique elements in the
sequence, we could easily put the elements in a set and return its contents.
However, that won't be *stable*: because a set has no defined order, the input
elements might get reordered in the result. To fix this, we can write an
extension that maintains the order by using an internal `Set` for bookkeeping:

*/

//#-editable-code
extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter {
            if seen.contains($0) {
                return false
            } else {
                seen.insert($0)
                return true
            }
        }
    }
}

[1,2,3,12,1,3,4,5,6,4,6].unique()
//#-end-editable-code

/*:
The method above allows us to find all unique elements in a sequence while still
maintaining the original order (with the constraint that the elements must be
`Hashable`). Inside the closure we pass to `filter`, we refer to the variable
`seen` that we defined outside the closure, thus maintaining state over multiple
iterations of the closure. In the chapter on functions, we'll look at this
technique in more detail.

*/
