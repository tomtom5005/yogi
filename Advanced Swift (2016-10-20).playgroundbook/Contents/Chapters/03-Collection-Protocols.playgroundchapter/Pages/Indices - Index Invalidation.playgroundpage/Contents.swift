/*:
### Index Invalidation

Indices may become invalid when the collection is mutated. Invalidation could
mean that the index remains valid but now addresses a different element or that
the index is no longer a valid index for the collection and using it to access
the collection will trap. This should be intuitively clear when you consider
arrays. When you append an element, all existing indices remain valid. When you
remove the first element, an existing index to the last element becomes invalid.
Meanwhile smaller indices remain valid, but the elements they point to have
changed.

A dictionary index remains stable when new key-value pairs are added *until* the
dictionary grows so much that it triggers a reallocation. This is because the
element's location in the dictionary's storage buffer doesn't change, as
elements are inserted until the buffer has to be resized, forcing all elements
to be rehashed. Removing elements from a dictionary [invalidates
indices](https://github.com/apple/swift/blob/master/docs/IndexInvalidation.rst).

An index should be a dumb value that only stores the minimal amount of
information required to describe an element's position. In particular, indices
shouldn't keep a reference to their collection, if at all possible. Similarly, a
collection usually can't distinguish one of its "own" indices from one that came
from another collection of the same type. Again, this is trivially evident for
arrays. Of course, you can use an integer index that was derived from one array
to index another:

*/

//#-editable-code
let numbers = [1,2,3,4]
let squares = numbers.map { $0 * $0 }
let numbersIndex = numbers.index(of: 4)!
squares[numbersIndex]
//#-end-editable-code

/*:
This also works with opaque index types, such as `String.Index`. In this
example, we use one string's `startIndex` to access the first character of
another string:

*/

//#-editable-code
let hello = "Hello"
let world = "World"
let helloIdx = hello.startIndex
world[helloIdx]
//#-end-editable-code

/*:
However, the fact that you can do this doesn't mean it's generally a good idea.
If we had used the index to subscript into an empty string, the program would've
crashed because the index was out of bounds.

There are legitimate use cases for sharing indices between collections, though.
The biggest one is working with slices. Subsequences usually share the
underlying storage with their base collection, so an index of the base
collection will address the same element in the slice.

*/
