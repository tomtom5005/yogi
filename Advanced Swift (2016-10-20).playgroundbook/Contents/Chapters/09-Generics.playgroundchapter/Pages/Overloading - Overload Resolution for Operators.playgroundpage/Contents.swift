/*:
### Overload Resolution for Operators

The compiler exhibits some surprising behavior when it comes to the resolution
of overloaded operators. As [Matt Gallagher points
out](http://www.cocoawithlove.com/blog/2016/07/12/type-checker-issues.html), the
type checker always favors non-generic overloads over generic variants, even
when the generic version would be the better choice (and the one which would be
chosen if we were talking about a normal function).

Going back to the exponentiation example from above, let's define a custom
operator named `**` for the same operation:

*/

//#-hidden-code
import Darwin
//#-end-hidden-code

//#-editable-code
// Exponentiation has higher precedence than multiplication
precedencegroup ExponentiationPrecedence {
    associativity: left
    higherThan: MultiplicationPrecedence
}
infix operator **: ExponentiationPrecedence

func **(lhs: Double, rhs: Double) -> Double {
    return pow(lhs, rhs)
}
func **(lhs: Float, rhs: Float) -> Float {
    return powf(lhs, rhs)
}

2.0 ** 3.0
//#-end-editable-code

/*:
The above code is equivalent to the `raise` function we implemented in the
previous section. Let's add another overload for integers next. We want
exponentiation to work for all integer types, so we define a generic overload
for all types conforming to `SignedInteger` (we'd need another overload for
`UnsignedInteger`, not shown here):

*/

//#-editable-code
func **<I: SignedInteger>(lhs: I, rhs: I) -> I {
    // Cast to IntMax, use Double overload to compute result,
    // then numericCast to return type.
    let result = Double(lhs.toIntMax()) ** Double(rhs.toIntMax())
    return numericCast(IntMax(result))
}
//#-end-editable-code

/*:
This looks like it should work, but if we now call `**` with two integer
literals, the compiler complains about an ambiguous use of the `**` operator:

``` swift-example
2 ** 3 // Error: Ambiguous use of operator '**'
```

The explanation for why this happens brings us back to what we said at the
beginning of this section: when resolving overloaded operators, the type checker
always favors non-generic over generic overloads. Apparently, the compiler
ignores the generic overload for integers and then raises the error because it
can't decide whether it should call the overload for `Double` or the one for
`Float` — both are equally valid choices for two integer literal arguments. To
convince the compiler to pick the correct overload, we have to explicitly cast
at least one of the arguments to an integer type, or else provide an explicit
result type:

*/

//#-editable-code
let intResult: Int = 2 ** 3
//#-end-editable-code

/*:
The compiler only behaves in this manner for operators — a generic overload of
the `raise` function for `SignedInteger` would work just fine without
introducing ambiguities. The reason for this discrepancy comes down to
performance: the Swift team considers the reduction of complexity the type
checker has to deal with significant enough to warrant the use of this simpler
but sometimes incorrect overload resolution model for operators.

*/
