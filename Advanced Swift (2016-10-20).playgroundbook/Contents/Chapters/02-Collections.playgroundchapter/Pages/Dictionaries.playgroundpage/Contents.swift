/*:
## Dictionaries

Another key data structure in Swift is `Dictionary`. A dictionary contains keys
with corresponding values; duplicate keys aren't supported. Retrieving a value
by its key takes constant time on average, whereas searching an array for a
particular element grows linearly with the array's size. Unlike arrays,
dictionaries aren't ordered. The order in which pairs are enumerated in a `for`
loop is undefined.

In the following example, we use a dictionary as the model data for a fictional
settings screen in a smartphone app. The screen consists of a list of settings,
and each individual setting has a name (the keys in our dictionary) and a value.
A value can be one of several data types, such as text, numbers, or booleans. We
use an `enum` with associated values to model this:

*/

//#-editable-code
enum Setting {
    case text(String)
    case int(Int)
    case bool(Bool)
}

let defaultSettings: [String:Setting] = [
    "Airplane Mode": .bool(true),
    "Name": .text("My iPhone"),
]
//#-end-editable-code

//#-editable-code
defaultSettings["Name"]
//#-end-editable-code

/*:
We use subscripting to get the value of a setting (for example,
`defaultSettings["Name"]`). Dictionary lookup always returns an *optional
value*. When the specified key doesn't exist, it returns `nil`. Contrast this
with arrays, which respond to an out-of-bounds access by crashing the program.

The rationale for this difference is that array indices and dictionary keys are
used very differently. We've already seen that it's quite rare that you actually
need to work with array indices directly. And if you do, an array index is
usually directly derived from the array in some way (e.g. from a range like
`0..<array.count`); thus, using an invalid index is a programmer error. On the
other hand, it's very common for dictionary keys to come from some source other
than the dictionary itself.

Unlike arrays, dictionaries are also sparse. The existence of the value under
the key `"name"` doesn't tell you anything about whether or not the key
"address" also exists.

*/
