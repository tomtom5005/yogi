/*:
### Mutation

Just like with arrays, dictionaries defined using `let` are immutable: no
entries can be added, removed, or changed. And just like with arrays, we can
define a mutable variant using `var`. To remove a value from a dictionary, we
can either set it to `nil` using subscripting or call `removeValue(forKey:)`.
The latter additionally returns the deleted value, or `nil` if the key didn't
exist. If we want to take an immutable dictionary and make changes to it, we
have to make a copy:

*/

//#-hidden-code
enum Setting {
    case text(String)
    case int(Int)
    case bool(Bool)
}

let defaultSettings: [String:Setting] = [
    "Airplane Mode": .bool(true),
    "Name": .text("My iPhone"),
]
//#-end-hidden-code

//#-editable-code
var localizedSettings = defaultSettings
localizedSettings["Name"] = .text("Mein iPhone")
localizedSettings["Do Not Disturb"] = .bool(true)
//#-end-editable-code

/*:
Note that, again, the value of `defaultSettings` didn't change. As with key
removal, an alternative to updating via subscript is the
`updateValue(_:forKey:)` method, which returns the previous value (if any):

*/

//#-editable-code
let oldName = localizedSettings
    .updateValue(.text("Il mio iPhone"), forKey: "Name")
localizedSettings["Name"]
oldName
//#-end-editable-code
