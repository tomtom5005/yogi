/*:
### Shuffling Collections

To help cement this concept, here's another example, this time an implementation
of the [Fisher-Yates](https://en.wikipedia.org/wiki/Fisher–Yates_shuffle)
shuffling algorithm:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
extension Array {
    mutating func shuffle() {
        for i in 0..<(count - 1) {
            let j = Int(arc4random_uniform(UInt32(count - i))) + i

            // Guard against the (slightly pedantic) requirement of swap that you 
            // not try to swap an element with itself.
            guard i != j else { continue }

            swap(&self[i], &self[j])
        }
    }

    /// Non-mutating variant of `shuffle`
    func shuffled() -> [Element] {
        var clone = self
        clone.shuffle()
        return clone
    }
}
//#-end-editable-code

/*:
Again, we've followed a standard library practice: providing an in-place
version, since this can be done more efficiently, and then providing a
non-mutating version that generates a shuffled copy of the array, which can be
implemented in terms of the in-place version.

*/
