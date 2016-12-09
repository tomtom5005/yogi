/*:
However, this is pretty ugly. Really, what's needed is some kind of `if not let`
— which is exactly what `guard let` does:

*/

//#-editable-code
extension String {
    var fileExtension: String? {
        guard let period = characters.index(of: ".") else { return nil }
        let extensionRange = index(after: period)..<characters.endIndex
        return self[extensionRange]
    }
}

"hello.txt".fileExtension
//#-end-editable-code

/*:
Anything can go in the `else` clause here, including multiple statements just
like an `if ... else`. The only requirement is that the end of the `else` must
leave the current scope. That might mean `return`, or it might mean calling
`fatalError` (or any other function that returns `Never`). If the `guard` were
in a loop, it could be via `break` or `continue`.

> A function that has the return type `Never` signals to the compiler that it'll
> never return. There are two common types of functions that do this: those that
> abort the program, such as `fatalError`; and those that run for the entire
> lifetime of the program, like `dispatchMain`. The compiler uses this
> information for its control flow diagnostics. For example, the `else` branch
> of a `guard` statement must either exit the current scope or call one of these
> never-returning functions.
> 
> `Never` is what's called an *uninhabited type*. It's a type that has no valid
> values and thus can't be constructed. Its only purpose is its signaling role
> for the compiler. A function declared to return an uninhabited type can never
> return normally. In Swift, an uninhabited type is implemented as an `enum`
> that has no cases.
> 
> You won't usually need to define your own never-returning functions unless you
> write a wrapper for `fatalError` or `preconditionFailure`. One interesting use
> case is while you're writing new code: say you're working on a complex
> `switch` statement, gradually filling in all the cases, and the compiler is
> bombarding you with error messages for empty case labels or missing return
> values, while all you'd like to do is concentrate on the one case you're
> working on. In this situation, a few carefully placed calls to `fatalError()`
> can do wonders to silence the compiler. Consider writing a function called
> `unimplemented()` in order to better communicate the temporary nature of these
> calls:
> 
> ``` swift
> func unimplemented() -> Never {
>     fatalError("This code path is not implemented yet.")
> }
> ```

Of course, `guard` isn't limited to binding. Guard can take any condition you
might find in a regular `if` statement, so the empty array example could be
rewritten with it:

*/

//#-editable-code
func doStuff(withArray a: [Int]) {
    guard !a.isEmpty else { return }
    // now, use a[0] safely
}
//#-end-editable-code

/*:
Unlike the optional binding case, this `guard` isn't a big win — in fact, it's
slightly more verbose than the original return. But it's still worth considering
doing this with any early exit situation. For one, sometimes (though not in this
case) the inversion of the boolean condition can make things clearer.
Additionally, `guard` is a clear signal when reading the code; it says: "We only
continue if the following condition holds." Finally, the Swift compiler will
check that you're definitely exiting the current scope and raise a compilation
error if you don't. For this reason, we'd suggest using `guard` even when an
`if` would do.

*/
