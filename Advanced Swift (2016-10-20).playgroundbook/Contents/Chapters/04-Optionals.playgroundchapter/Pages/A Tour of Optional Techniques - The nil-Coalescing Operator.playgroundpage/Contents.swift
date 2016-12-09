/*:
### The `nil`-Coalescing Operator

Often you want to unwrap an optional, replacing `nil` with some default value.
This is a job for the `nil`-coalescing operator:

*/

//#-editable-code
let stringteger = "1"
let number = Int(stringteger) ?? 0
//#-end-editable-code

/*:
So if the string is of an integer, `number` will be that integer, unwrapped. If
it isn't, and `Int.init` returns `nil`, the default value of `0` will be
substituted. So `lhs ?? rhs` is analogous to the code `lhs != nil ? lhs! : rhs`.

"Big deal\!" Objective-C developers might say. "We've had the `?:` for ages."
And `??` is very similar to Objective-C's `?:`. But there are some differences,
so it's worth stressing an important point when thinking about optionals in
Swift: optionals are *not* pointers.

Yes, you'll often encounter optionals combined with references when dealing with
Objective-C libraries. But optionals, as we've seen, can also wrap value types.
So `number` in the above example is just an `Int`, not an `NSNumber`.

Through the use of optionals, you can guard against much more than just null
pointers. Consider the case where you want to access the first value of an array
— but in case the array is empty, you want to provide a default:

*/

//#-editable-code
let array = [1,2,3]
!array.isEmpty ? array[0] : 0
//#-end-editable-code

/*:
Because Swift arrays provide a `first` property that's `nil` if the array is
empty, you can use the `nil`-coalescing operator instead:

*/

//#-editable-code
array.first ?? 0
//#-end-editable-code

/*:
This is cleaner and clearer — the intent (grab the first element in the array)
is up front, with the default tacked on the end, joined with a `??` that signals
"this is a default value." Compare this with the ternary version, which starts
first with the check, then the value, then the default. And the check is
awkwardly negated (the alternative being to put the default in the middle and
the actual value on the end). And, as is the case with optionals, it's
impossible to forget that `first` is optional and accidentally use it without
the check, because the compiler will stop you if you try.

Whenever you find yourself guarding a statement with a check to make sure the
statement is valid, it's a good sign optionals would be a better solution.
Suppose that instead of an empty array, you're checking a value that's within
the array bounds:

*/

//#-editable-code
array.count > 5 ? array[5] : 0
//#-end-editable-code

/*:
Unlike `first` and `last`, getting an element out of an array by its index
doesn't return an `Optional`. But it's easy to extend `Array` to add this
functionality:

*/

//#-editable-code
extension Array {
    subscript(safe idx: Int) -> Element? {
        return idx < endIndex ? self[idx] : nil
    }
}
//#-end-editable-code

/*:
This now allows you to write the following:

*/

//#-editable-code
array[safe: 5] ?? 0
//#-end-editable-code
