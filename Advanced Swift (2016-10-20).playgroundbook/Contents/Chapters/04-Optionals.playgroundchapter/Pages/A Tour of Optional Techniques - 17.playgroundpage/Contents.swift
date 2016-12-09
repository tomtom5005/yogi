/*:
## When to Force-Unwrap

Given all these techniques for cleanly unwrapping optionals, when should you use
`!`, the force-unwrap operator? There are many opinions on this scattered
throughout the Internet, such as "never," "whenever it makes the code clearer,"
and "when you can't avoid it." We propose the following rule, which encompasses
most of them:

> Use `!` when you're so certain that a value won't be `nil` that you *want*
> your program to crash if it ever is.

As an example, take the implementation of `flatten`:

*/

//#-editable-code
func flatten_sample_impl<S: Sequence, T>
    (source: S) -> [T] where S.Iterator.Element == T? {
    let filtered = source.lazy.filter { $0 != nil }
    return filtered.map { $0! }
}
//#-end-editable-code

/*:
Here, there's no possible way in the `map` that `$0!` will ever hit a `nil`,
since the `nil` elements were all filtered out in the preceding filter step.
This function could certainly be written to eliminate the force-unwrap operator
by looping over the array and adding non-`nil` values into an array. But the
`filter`/`map` version is cleaner and probably clearer, so the `!` could be
justified.

But these cases are pretty rare. If you have full mastery of all the unwrapping
techniques described in this chapter, chances are that there's a better way.
Whenever you do find yourself reaching for `!`, it's worth taking a step back
and wondering if there really is no other way. For example, we could've also
implemented `flatten` using a single method call: `source.flatMap { $0 }`.

As another example, consider the following code that fetches all the keys in a
dictionary with values matching a certain condition:

*/

//#-editable-code
let ages = [
    "Tim":  53, "Angela": 54, "Craig": 44,
    "Jony": 47, "Chris": 37, "Michael": 34,
]
ages.keys
    .filter { name in ages[name]! < 50 }
    .sorted()
//#-end-editable-code

/*:
Here, the `!` is perfectly safe — since all the keys came from the dictionary,
there's no possible way in which a key could be missing from the dictionary.

But you could also rewrite the statement to eliminate the need for a
force-unwrap altogether. Using the fact that dictionaries present themselves as
sequences of key/value pairs, you could just filter this sequence and then run
it through a map to remove the value:

*/

//#-editable-code
ages.filter { (_, age) in age < 50 }
    .map { (name, _) in name }
    .sorted()
//#-end-editable-code

/*:
This version even has a performance benefit: avoiding unnecessary key lookups.

Nonetheless, sometimes life hands you an optional, and you know *for certain*
that it isn't `nil`. So certain are you of this that you'd *rather* your program
crash than continue, because it'd mean a very nasty bug in your logic. Better to
trap than to continue under those circumstances, so `!` acts as a combined
unwrap-or-error operator in one handy character. This approach is often a better
move than just using the `nil` chaining or coalescing operators to sweep
theoretically impossible situations under the carpet.

### Improving Force-Unwrap Error Messages

That said, even when you're force-unwrapping an optional value, you have options
other than using the `!` operator. When your program does error, you don't get
much by way of description as to why in the output log.

Chances are, you'll leave a comment as to why you're justified in
force-unwrapping. So why not have that comment serve as the error message too?
Here's an operator, `!!`; it combines unwrapping with supplying a more
descriptive error message to be logged when the application exits:

*/

//#-editable-code
infix operator !!

func !! <T>(wrapped: T?, failureText: @autoclosure () -> String) -> T {
    if let x = wrapped { return x }
    fatalError(failureText())
}
//#-end-editable-code

/*:
Now you can write a more descriptive error message, including the value you
expected to be able to unwrap:

``` swift-example
let s = "foo"
let i = Int(s) !! "Expecting integer, got \"\(s)\""
```

The `@autoclosure` annotation makes sure that we only evaluate the second
operand when needed. In the chapter on functions, we'll go into this in more
detail.

*/
