/*:
### Some Useful Dictionary Extensions

What if we wanted to combine the default settings dictionary with any custom
settings the user has changed? Custom settings should override defaults, but the
resulting dictionary should still include default values for any keys that
haven't been customized. Essentially, we want to merge two dictionaries, where
the dictionary that's being merged in overwrites duplicate keys. The standard
library doesn't include a function for this, so let's write one.

We can extend `Dictionary` with a `merge` method that takes the key-value pairs
to be merged in as its only argument. We could make this argument another
`Dictionary`, but this is a good opportunity for a more generic solution. Our
requirements for the argument are that it must be a sequence we can loop over,
and the sequence's elements must be key-value pairs of the same type as the
receiving dictionary. Any `Sequence` whose `Iterator.Element` is a `(Key,
Value)` pair meets these requirements, so that's what the method's generic
constraints should express (`Key` and `Value` here are the generic type
parameters of the `Dictionary` type we're extending):

*/

//#-editable-code
extension Dictionary {
    mutating func merge<S>(_ other: S)
        where S: Sequence, S.Iterator.Element == (key: Key, value: Value) {
        for (k, v) in other {
            self[k] = v
        }
    }
}
//#-end-editable-code

/*:
We can use this to merge one dictionary into another, as shown in the following
example, but the method argument could just as well be an array of key-value
pairs or any other sequence:

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
var settings = defaultSettings
let overriddenSettings: [String:Setting] = ["Name": .text("Jane's iPhone")]
settings.merge(overriddenSettings)
settings
//#-end-editable-code

/*:
Another interesting extension is creating a dictionary from a sequence of `(Key,
Value)` pairs. The standard library provides a similar initializer for arrays
that comes up very frequently; you use it every time you create an array from a
range (`Array(1...10)`) or convert an `ArraySlice` back into a proper array
(`Array(someSlice)`). However, there's no such initializer for `Dictionary`.
(There is a Swift-Evolution proposal [to add
one](https://github.com/apple/swift-evolution/blob/master/proposals/0100-add-sequence-based-init-and-merge-to-dictionary.md),
though, so we may see it in the future.)

We can start with an empty dictionary and then just merge in the sequence. This
makes use of the `merge` method defined above to do the heavy lifting:

*/

//#-editable-code
extension Dictionary {
    init<S: Sequence>(_ sequence: S)
        where S.Iterator.Element == (key: Key, value: Value) {
        self = [:]
        self.merge(sequence)
    }
}

// All alarms are turned off by default
let defaultAlarms = (1..<5).map { (key: "Alarm \($0)", value: false) }
let alarmsDictionary = Dictionary(defaultAlarms)
//#-end-editable-code

/*:
A third useful extension is a `map` over the dictionary's values. Because
`Dictionary` is a `Sequence`, it already has a `map` method that produces an
array. However, sometimes we want to keep the dictionary structure intact and
only transform its values. Our `mapValues` method first calls the standard `map`
to create an array of *(key, transformed value)* pairs and then uses the new
initializer we defined above to turn it back into a dictionary:

*/

//#-editable-code
extension Dictionary {
    func mapValues<NewValue>(transform: (Value) -> NewValue)
        -> [Key:NewValue] {
            return Dictionary<Key, NewValue>(map { (key, value) in
                return (key, transform(value))
            })
    }
}

let settingsAsStrings = settings.mapValues { setting -> String in
    switch setting {
    case .text(let text): return text
    case .int(let number): return String(number)
    case .bool(let value): return String(value)
    }
}
settingsAsStrings
//#-end-editable-code
