/*:
By contrast, the Ruby and Python code is more along the lines of the following:

*/

//#-editable-code
var a: [() -> Int] = []

do {
    var g = (1...3).makeIterator()
    var i: Int
    var o: Int? = g.next()
    while o != nil {
        i = o!
        a.append { i }
        o = g.next()
    }
}
//#-end-editable-code

/*:
Here, `i` is declared *outside* the loop — and reused — so every closure
captures the same `i`. If you run each of them, they'll all return 3. The `do`
is there because, despite `i` being declared outside the loop, it's still scoped
in such a way that it isn't *accessible* outside that loop — it's sandwiched in
a narrow outer shell.

C\# had the same behavior as Ruby until C\# 5, when it was decided that this
behavior was dangerous enough to justify a breaking change in order to work like
Swift.

*/
