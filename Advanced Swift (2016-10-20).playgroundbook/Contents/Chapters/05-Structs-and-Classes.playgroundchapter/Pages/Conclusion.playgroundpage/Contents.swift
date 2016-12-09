/*:
## Conclusion

We've looked at the differences between structs and classes in Swift. For
entities (needing identity), classes are a better choice. For value types,
structs are a better choice. When building structs that contain objects, we
often need to take extra steps to ensure that they're really value types — for
example, by implementing copy-on-write. We've looked at how to prevent reference
cycles when dealing with classes. Often, a problem can be solved with either
structs or classes, and what you choose depends on your needs. However, even
problems that are classically solved using references can often benefit from
values.

*/
