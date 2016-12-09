/*:
### Comparing Optionals

Similar to `==`, there used to be implementations of `<`, `>`, `<=`, and `>=`
for optionals. In
[SE-0121](https://github.com/apple/swift-evolution/blob/master/proposals/0121-remove-optional-comparison-operators.md),
these comparison operators were removed because they can easily yield unexpected
results.

For example, `nil < .some(_)` would return `true`. In combination with
higher-order functions or optional chaining, this can be very surprising.
Consider the following example:

``` swift-example
let temps = ["-459.67", "98.6", "0", "warm"]
let belowFreezing = temps.filter { Double($0) < 0 }
```

Because `Double("warm")` will return `nil` and `nil` is less than `0`, it'll be
included in the `belowFreezing` temperatures. This is unexpected indeed.

*/
