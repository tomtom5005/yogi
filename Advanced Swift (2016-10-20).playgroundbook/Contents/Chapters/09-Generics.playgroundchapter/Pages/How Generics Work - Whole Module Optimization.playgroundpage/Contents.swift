/*:
### Whole Module Optimization

Generic specialization only works if the compiler can see the full definition of
the generic type or function it wants to specialize. Since Swift compiles source
files individually by default, it can only perform specialization if the code
that uses the generic code resides in the same file as the generic code.

Since this is a pretty big limitation, the compiler has a flag to enable *whole
module optimization*. In this mode, all files in the current module are
optimized together as if they were one file, allowing generic specializations
across the full codebase. You can enable whole module optimization by passing
`-whole-module-optimization` to `swiftc`. Be sure to do so in release builds
(and possibly also in debug builds), because the performance gains can be huge.
The drawback is longer compilation times.

> Whole module optimization enables other important optimizations. For example,
> the optimizer will recognize when an `internal` class has no subclasses in the
> entire module. Since the `internal` modifier makes sure the class isn't
> visible outside the module, this means the compiler can replace dynamic
> dispatch with static dispatch for all methods of this class.

Generic specialization requires the definition of the generic type or function
to be visible, and therefore can't be performed across module boundaries. This
means your generic code will likely be faster for clients that reside in the
same module where the code is defined than for external clients. The only
exception to this is generic code in the standard library. Because the standard
library is so important and used by every other module, definitions in the
standard library are visible in all modules and thus available for
specialization.

Swift includes a [semi-official
attribute](https://lists.swift.org/pipermail/swift-dev/Week-of-Mon-20160314/001449.html)
called `@_specialize` that allows you to make specialized versions of your
generic code available to other modules. You must specify the list of types you
want to specialize, so this only helps if you know your code will mostly be used
with a limited number of types. Making specialized versions of our `min`
function for integers and strings available to other modules would look like
this:

*/

//#-editable-code
@_specialize(Int)
@_specialize(String)
public func min<T: Comparable>(_ x: T, _ y: T) -> T {
    return y < x ? y : x
}
//#-end-editable-code

/*:
Notice we added `public` — it makes no sense to specify `@_specialize` for
`internal`, `fileprivate`, or `private` APIs, since those are not visible
outside the module anyway.

*/
