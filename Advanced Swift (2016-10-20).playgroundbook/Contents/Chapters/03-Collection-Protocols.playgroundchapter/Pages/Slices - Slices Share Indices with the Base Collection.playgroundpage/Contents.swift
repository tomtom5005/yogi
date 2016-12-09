/*:
### Slices Share Indices with the Base Collection

Indices of a slice can generally be used interchangeably with indices of the
original collection. This isn't a formal requirement, but all slice types in the
standard library behave in this way, so it's a good rule to follow in your own
implementations.

An important implication of this model is that, even when using integer indices,
a collection's index won't necessarily start at zero. Here's an example of the
start and end indices of an array slice:

*/

//#-editable-code
let cities = ["New York", "Rio", "London", "Berlin", 
    "Rome", "Beijing", "Tokyo", "Sydney"]
let slice = cities[2...4]
cities.startIndex
cities.endIndex
slice.startIndex
slice.endIndex
//#-end-editable-code

/*:
Accidentally accessing `slice[0]` in this situation will crash your program.
This is another reason to always prefer constructs like `for x in collection` or
`for index in collection.indices` over manual index math if possible — with one
exception: if you mutate a collection while iterating over its `indices`, any
strong reference the `indices` object holds to the original collection will
defeat the copy-on-write optimizations and may cause an unwanted copy to be
made. Depending on the size of the collection, this can have a significant
negative performance impact. (Not all collections use an `Indices` type that
strongly references the base collection, but many do.)

To avoid this, you can replace the `for` loop with a `while` loop and advance
the index manually in each iteration, thus avoiding the `indices` property. Just
remember that if you do this, always start the loop at `collection.startIndex`
and not at `0`.

*/
