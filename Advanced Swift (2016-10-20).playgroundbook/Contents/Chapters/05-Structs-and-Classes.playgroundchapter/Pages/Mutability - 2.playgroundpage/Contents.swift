/*:
Now let's consider the same example, but using Swift arrays:

*/

//#-editable-code
var mutableArray = [1, 2, 3]
for _ in mutableArray {
    mutableArray.removeLast()
}
//#-end-editable-code

/*:
This example doesn't crash, because the iterator keeps a local, independent copy
of the array. To see this even more clearly, you could write `removeAll` instead
of `removeLast`, and if you open it up in a playground, you'll see that the
statement gets executed three times because the iterator's copy of the array
still contains three elements.

*/
