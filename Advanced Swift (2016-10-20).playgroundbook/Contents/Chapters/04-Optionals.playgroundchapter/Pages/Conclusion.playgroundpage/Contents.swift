/*:
## Conclusion

Optionals are very useful when dealing with values that might or might not be
`nil`. Rather than using magic values such as `NSNotFound`, we can use `nil` to
indicate a value is empty. Swift has many built-in features that work with
optionals so that you can avoid forced unwrapping of optionals. Implicitly
unwrapped optionals are useful when working with legacy code, but normal
optionals should always be preferred (if possible). Finally, if you need more
than just an optional (for example, you also need an error message if the result
isn't present), you can use errors, which we cover in the errors chapter.

*/
