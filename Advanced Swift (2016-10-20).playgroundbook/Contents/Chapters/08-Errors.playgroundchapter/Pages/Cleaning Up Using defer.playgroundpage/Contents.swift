/*:
## Cleaning Up Using `defer`

Let's go back to the `contents(ofFile:)` function from the beginning of this
chapter for a minute and have a look at the implementation. In many languages,
it's common to have a `try`/`finally` construct, where the block marked with
`finally` is always executed when the function returns, regardless of whether or
not an error was thrown. The `defer` keyword in Swift has a similar purpose but
works a bit differently. Like `finally`, a `defer` block is always executed when
a scope is exited, regardless of the reason of exiting — whether it's because a
value is successfully returned, because an error happened, or any other reason.
Unlike `finally`, a `defer` block doesn't require a leading `try` or `do` block,
and it's more flexible in terms of where you place it in your code:

*/

//#-hidden-code
import Foundation
func process(file: Int32) throws -> String { return "" }
//#-end-hidden-code

//#-editable-code
func contents(ofFile filename: String) throws -> String
{
    let file = open("test.txt", O_RDONLY)
    defer { close(file) }
    let contents = try process(file: file)
    return contents
}
//#-end-editable-code

/*:
While `defer` is often used together with error handling, it can be useful in
other contexts too — for example, when you want to keep the code for
initialization and cleanup of a resource close together. Putting related parts
of the code close to each other can make your code significantly more readable,
especially in longer functions.

The standard library uses `defer` in multiple places where a function needs to
increment a counter *and* return the counter's previous value. This saves
creating a local variable for the return value; `defer` essentially serves as a
replacement for the removed postfix increment operator. Here's a typical example
from the implementation of `EnumeratedIterator`:

``` swift-example
struct EnumeratedIterator<Base: IteratorProtocol>: IteratorProtocol, Sequence {
    internal var _base: Base
    internal var _count: Int
    ...
    func next() -> Element? {
        guard let b = _base.next() else { return nil }
        defer { _count += 1 }
        return (offset: _count, element: b)
    }
}
```

If there are multiple `defer` blocks in the same scope, they're executed in
reverse order; you can think of them as a stack. At first, it might feel strange
that the `defer` blocks run in reverse order. However, if we look at an example,
it should quickly make sense:

``` swift-example
guard let database = openDatabase(...) else { return }
defer { closeDatabase(database) }
guard let connection = openConnection(database) else { return }
defer { closeConnection(connection) }
guard let result = runQuery(connection, ...) else { return }
```

If an error occurs — for example, during the `runQuery` call — we want to close
the connection first and the database second. Because the `defer` is executed in
reverse order, this happens automatically. The `runQuery` depends on
`openConnection`, which in turn depends on `openDatabase`. Therefore, cleaning
these resources up needs to happen in reverse order.

There are some cases in which `defer` blocks don't get executed: when your
program segfaults, or when it raises a fatal error (e.g. using `fatalError` or
by force-unwrapping a `nil`), all execution halts immediately.

*/
