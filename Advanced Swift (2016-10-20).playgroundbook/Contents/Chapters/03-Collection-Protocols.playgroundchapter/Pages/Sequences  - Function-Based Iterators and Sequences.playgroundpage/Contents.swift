/*:
#### Function-Based Iterators and Sequences

`AnyIterator` has a second initializer that takes the `next` function directly
as its argument. Together with the corresponding `AnySequence` type, this allows
us to create iterators and sequences without defining any new types. For
example, we could've defined the Fibonacci iterator alternatively as a function
that returns an `AnyIterator`:

*/

//#-editable-code
func fibsIterator() -> AnyIterator<Int> {
    var state = (0, 1)
    return AnyIterator {
        let upcomingNumber = state.0
        state = (state.1, state.0 + state.1)
        return upcomingNumber
    }
}
//#-end-editable-code

/*:
By keeping the `state` variable outside of the iterator's `next` closure and
capturing it inside the closure, the closure can mutate the state every time
it's invoked. There's only one functional difference between the two Fibonacci
iterators: the definition using a custom struct has value semantics, and the
definition using `AnyIterator` doesn't.

Creating a sequence out of this is even easier now because `AnySequence`
provides an initializer that takes a function, which in turn produces an
iterator:

*/

//#-editable-code
let fibsSequence = AnySequence(fibsIterator)
Array(fibsSequence.prefix(10))
//#-end-editable-code

/*:
Another alternative is to use the `sequence` function that was introduced in
Swift 3. The function has two variants. The first, `sequence(first:next:)`,
returns a sequence whose first element is the first argument you passed in;
subsequent elements are produced by the closure passed in the `next` argument.
In this example, we generate a sequence of random numbers, each smaller than the
previous one, stopping when we reach zero:

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
let randomNumbers = sequence(first: 100) { (previous: UInt32) in
    let newValue = arc4random_uniform(previous)
    guard newValue > 0 else {
        return nil
    }
    return newValue
}
Array(randomNumbers)
//#-end-editable-code

/*:
The other variant, `sequence(state:next:)`, is even more powerful because it can
keep some arbitrary mutable state around between invocations of the `next`
closure. We can use this to build the Fibonacci sequence with a single function
call:

*/

//#-editable-code
let fibsSequence2 = sequence(state: (0, 1)) {
    // The compiler needs a little type inference help here
    (state: inout (Int, Int)) -> Int? in
    let upcomingNumber = state.0
    state = (state.1, state.0 + state.1)
    return upcomingNumber
}

Array(fibsSequence2.prefix(10))
//#-end-editable-code

/*:
> The return type of `sequence(first:next:)` and `sequence(state:next:)` is
> `UnfoldSequence`. This term comes from functional programming, where the same
> operation is often called *unfold*. `sequence` is the natural counterpart to
> `reduce` (which is often called *fold* in functional languages). Where
> `reduce` reduces (or *folds*) a sequence into a single return value,
> `sequence` *unfolds* a single value to generate a sequence.

The two `sequence` functions are extremely versatile. They're often a good fit
for replacing a traditional C-style `for` loop that uses non-linear math.

*/
