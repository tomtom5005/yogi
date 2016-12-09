/*:
#### Conforming to Sequence

An example of an iterator that produces a finite sequence is the following
`PrefixIterator`, which generates all prefixes of a string (including the string
itself). It starts at the beginning of the string, and with each call of `next`,
increments the slice of the string it returns by one character until it reaches
the end:

*/

//#-editable-code
struct PrefixIterator: IteratorProtocol {
    let string: String
    var offset: String.Index

    init(string: String) {
        self.string = string
        offset = string.startIndex
    }

    mutating func next() -> String? {
        guard offset < string.endIndex else { return nil }
        offset = string.index(after: offset)
        return string[string.startIndex..<offset]
    }
}
//#-end-editable-code

/*:
(`string[string.startIndex..<offset]` is a slicing operation that returns the
substring between the start and the offset — we'll talk more about slicing
later.)

With `PrefixIterator` in place, defining the accompanying `PrefixSequence` type
is easy. Again, it isn't necessary to specify the associated `Iterator` type
explicitly because the compiler can infer it from the return type of the
`makeIterator` method:

*/

//#-editable-code
struct PrefixSequence: Sequence {
    let string: String

    func makeIterator() -> PrefixIterator {
        return PrefixIterator(string: string)
    }
}
//#-end-editable-code

/*:
Now we can use a `for` loop to iterate over all the prefixes:

*/

//#-editable-code
for prefix in PrefixSequence(string: "Hello") {
    print(prefix)
}
//#-end-editable-code

/*:
Or we can perform any other operation provided by `Sequence`:

*/

//#-editable-code
PrefixSequence(string: "Hello").map { $0.uppercased() }
//#-end-editable-code

/*:
We can create sequences for `ConstantIterator` and `FibsIterator` in the same
way. We're not showing them here, but you may want to try this yourself. Just
keep in mind that these iterators create infinite sequences. Use a construct
like `for i in fibsSequence.prefix(10)` to slice off a finite piece.

*/
