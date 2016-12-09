/*:
## Flexibility through Functions 

In the built-in collections chapter, we talked about parameterizing behavior by
passing functions as arguments. Let's look at another example of this: sorting.

If you want to sort an array in Objective-C using Foundation, you're met with a
long list of different options. These provide a lot of flexibility and power,
but at the cost of complexity — even for the simplest method, you probably need
to read the documentation in order to know how to use it.

Sorting collections in Swift is simple:

*/

//#-editable-code
let myArray = [3, 1, 2]
myArray.sorted()
//#-end-editable-code

/*:
There are really four sort methods: the non-mutating variant `sorted(by:)`, and
the mutating `sort(by:)`, times two for the overloads that default to sorting
comparable things in ascending order. But the overloading means that when you
want the simplest case, `sorted()` is all you need. If you want to sort in a
different order, just supply a function:

*/

//#-editable-code
myArray.sorted(by: >)
//#-end-editable-code

/*:
You can also supply a function if your elements don't conform to `Comparable`
but *do* have a `<` operator, like tuples:

*/

//#-editable-code
var numberStrings = [(2, "two"), (1, "one"), (3, "three")]
numberStrings.sort(by: <)
numberStrings
//#-end-editable-code

/*:
Or, you can supply a more complicated function if you want to sort by some
arbitrary calculated criteria:

*/

//#-editable-code
let animals = ["elephant", "zebra", "dog"]
animals.sorted { lhs, rhs in
    let l = lhs.characters.reversed()
    let r = rhs.characters.reversed()
    return l.lexicographicallyPrecedes(r)
}
//#-end-editable-code

/*:
It's this last ability — the ability to use any comparison function to sort a
collection — that makes the Swift sort so powerful, and makes this one function
able to replicate much (if not all) of the functionality of the various sorting
methods in Foundation.

To demonstrate this, let's take a complex example inspired by the [Sort
Descriptor Programming
Topics](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/SortDescriptors/Articles/Creating.html)
guide in Apple's documentation. The `sortedArray(using:)` method on `NSArray` is
very flexible and a great example of the power of Objective-C's dynamic nature.
Support for selectors and dynamic dispatch is still there in Swift, but the
Swift standard library favors a more function-based approach instead. Later on,
we'll show a few techniques where functions as arguments, and treating functions
as data, can be used to get the same dynamic effects.

We'll start by defining a `Person` object. Because we want to show how
Objective-C's powerful runtime system works, we'll have to make this object an
`NSObject` subclass (in pure Swift, a struct might have been a better choice):

*/

//#-hidden-code
import Foundation
//#-end-hidden-code

//#-editable-code
final class Person: NSObject {
    var first: String
    var last: String
    var yearOfBirth: Int
    init(first: String, last: String, yearOfBirth: Int) {
        self.first = first
        self.last = last
        self.yearOfBirth = yearOfBirth
    }
}
//#-end-editable-code

//#-hidden-code
extension Person {
    override var description: String {
        return "\(first) \(last) (\(yearOfBirth))"
    }
}
//#-end-hidden-code

/*:
Let's also define an array of people with different names and birth years:

*/

//#-editable-code
let people = [
    Person(first: "Jo", last: "Smith", yearOfBirth: 1970),
    Person(first: "Joe", last: "Smith", yearOfBirth: 1970),
    Person(first: "Joe", last: "Smyth", yearOfBirth: 1970),
    Person(first: "Joanne", last: "smith", yearOfBirth: 1985),
    Person(first: "Joanne", last: "smith", yearOfBirth: 1970),
    Person(first: "Robert", last: "Jones", yearOfBirth: 1970),
]
//#-end-editable-code

/*:
We want to sort this array first by last name, then by first name, and finally
by birth year. We want to do this case insensitively and using the user's
locale. An `NSSortDescriptor` object describes how to order objects, and we can
use them to express the individual sorting criteria:

*/

//#-editable-code
let lastDescriptor = NSSortDescriptor(key: #keyPath(Person.last), 
    ascending: true,
    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
let firstDescriptor = NSSortDescriptor(key: #keyPath(Person.first), 
    ascending: true,
    selector: #selector(NSString.localizedCaseInsensitiveCompare(_:)))
let yearDescriptor = NSSortDescriptor(key: #keyPath(Person.yearOfBirth), 
    ascending: true)
//#-end-editable-code

/*:
To sort the array, we can use the `sortedArray(using:)` method on `NSArray`.
This takes a list of sort descriptors. To determine the order of two elements,
it starts by using the first sort descriptor and uses that result. However, if
two elements are equal according to the first descriptor, it uses the second
descriptor, and so on:

*/

//#-editable-code
let descriptors = [lastDescriptor, firstDescriptor, yearDescriptor]
(people as NSArray).sortedArray(using: descriptors)
//#-end-editable-code

/*:
A sort descriptor uses two runtime features of Objective-C: the `key` is a key
path, and [key-value
coding](https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/KeyValueCoding/Articles/KeyValueCoding.html)
is used to look up the value of that key at runtime. The `selector` parameter
takes a selector (which is really just a `String` describing a method name). At
runtime, the selector is turned into a comparison function, and when comparing
two objects, the values for the key are compared using that comparison function.

This is a pretty cool use of runtime programming, especially when you realize
the array of sort descriptors can be built at runtime, based on, say, a user
clicking a column heading.

How can we replicate this functionality using Swift's `sort`? It's simple to
replicate *parts* of the sort — for example, if you want to sort an array using
`localizedCaseInsensitiveCompare`:

*/

//#-editable-code
var strings = ["Hello", "hallo", "Hallo", "hello"]
strings.sort { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending}
strings
//#-end-editable-code

/*:
If you want to sort using just a single property of an object, that's also
simple:

*/

//#-editable-code
people.sorted { $0.yearOfBirth < $1.yearOfBirth }
//#-end-editable-code

/*:
This approach doesn't work so great when optional properties are combined with
methods like `localizedCaseInsensitiveCompare`, though — it gets ugly fast. For
example, consider sorting an array of filenames by file extension (using the
`fileExtension` property from the optionals chapter):

*/

//#-hidden-code
extension String {
    var fileExtension: String? {
        let period: String.Index
        if let idx = characters.index(of: ".") {
            period = idx
        } else {
            return nil
        }

        let extensionRange = characters.index(after: period)..<characters.endIndex
        return self[extensionRange]
    }
}
//#-end-hidden-code

//#-editable-code
var files = ["one", "file.h", "file.c", "test.h"]
files.sort { l, r in r.fileExtension.flatMap { 
    l.fileExtension?.localizedCaseInsensitiveCompare($0) 
} == .orderedAscending }
files
//#-end-editable-code

/*:
Later on, we'll make it easier to use optionals when sorting. However, for now,
we haven't even tried sorting by multiple properties. To sort by last name and
then first name, we can use the standard library's `lexicographicalCompare`
method. This takes two sequences and performs a phonebook-style comparison by
moving through each pair of elements until it finds one that isn't equal. So we
can build two arrays of the elements and use `lexicographicalCompare` to compare
them. It also takes a function to perform the comparison, so we'll put our use
of `localizedCaseInsensitiveCompare` in the function:

*/

//#-editable-code
people.sorted { p0, p1 in
    let left =  [p0.last, p0.first]
    let right = [p1.last, p1.first]

    return left.lexicographicallyPrecedes(right) {
        $0.localizedCaseInsensitiveCompare($1) == .orderedAscending
    }
}
//#-end-editable-code

/*:
At this point, we've almost replicated the functionality of the original sort in
roughly the same number of lines. But there's still a lot of room for
improvement: the building of arrays on every comparison is very inefficient, the
comparison is hardcoded, and we can't really sort by `yearOfBirth` using this
approach.

### Functions as Data

Rather than writing an even more complicated function that we can use to sort,
let's take a step back. So far, the sort descriptors were much clearer, but they
use runtime programming. The functions we wrote don't use runtime programming,
but they're not so easy to write (and read).

A sort descriptor is a way of describing the ordering of objects. Instead of
storing that information as a class, we can define a function to describe the
ordering of objects. The simplest possible definition takes two objects and
returns `true` if they're ordered correctly. This is also exactly the type that
the standard library's `sort(by:)` and `sorted(by:)` methods take as an
argument. It's helpful to define a generic `typealias` to describe sort
descriptors:

*/

//#-editable-code
typealias SortDescriptor<Value> = (Value, Value) -> Bool
//#-end-editable-code

/*:
As an example, we could define a sort descriptor that compares two `Person`
objects by year of birth, or a sort descriptor that sorts by last name:

*/

//#-editable-code
let sortByYear: SortDescriptor<Person> = { $0.yearOfBirth < $1.yearOfBirth }
let sortByLastName: SortDescriptor<Person> = { 
    $0.last.localizedCaseInsensitiveCompare($1.last) == .orderedAscending 
}
//#-end-editable-code

/*:
Rather than writing the sort descriptors by hand, we can write a function that
generates them. It's not nice that we have to write the same property twice: in
`sortByLastName`, we could have easily made a mistake and accidentally compared
`$0.last` with `$1.first`. Also, it's tedious to write these sort descriptors;
to sort by first name, it's probably easiest to copy and paste the
`sortByLastName` definition and modify it.

Instead of copying and pasting, we can define a function with an interface
that's a lot like `NSSortDescriptor`, but without the runtime programming. This
function takes a key and a comparison method, and it returns a sort descriptor
(the function, not the class `NSSortDescriptor`). Here, `key` isn't a string,
but a function. To compare two keys, we use a function, `areInIncreasingOrder`.
Finally, the result type is a function as well, even though this fact is
slightly obscured by the `typealias`:

*/

//#-editable-code
func sortDescriptor<Value, Key>(
    key: @escaping (Value) -> Key,
    _ areInIncreasingOrder: @escaping (Key, Key) -> Bool) 
    -> SortDescriptor<Value>
{
    return { areInIncreasingOrder(key($0), key($1)) }
}
//#-end-editable-code

/*:
This allows us to define `sortByYear` in a different way:

*/

//#-editable-code
let sortByYearAlt: SortDescriptor<Person> = 
    sortDescriptor(key: { $0.yearOfBirth }, <)
people.sorted(by: sortByYearAlt)
//#-end-editable-code

/*:
We can even define an overloaded variant that works for all `Comparable` types:

*/

//#-editable-code
func sortDescriptor<Value, Key>(key: @escaping (Value) -> Key)
    -> SortDescriptor<Value> where Key: Comparable
{
    return { key($0) < key($1) }
}
let sortByYearAlt2: SortDescriptor<Person> = 
    sortDescriptor(key: { $0.yearOfBirth })
//#-end-editable-code

/*:
Both `sortDescriptor` variants above work with functions that return a boolean
value. The `NSSortDescriptor` class has an initializer that takes a comparison
function such as `localizedCaseInsensitiveCompare`, which returns a three-way
value instead (ordered ascending, descending, or equal). Adding support for this
is easy as well:

*/

//#-editable-code
func sortDescriptor<Value, Key>(
    key: @escaping (Value) -> Key,
    ascending: Bool = true,
    _ comparator: @escaping (Key) -> (Key) -> ComparisonResult)
    -> SortDescriptor<Value>
{
    return { lhs, rhs in
        let order: ComparisonResult = ascending 
            ? .orderedAscending 
            : .orderedDescending
        return comparator(key(lhs))(key(rhs)) == order
    }
}
//#-end-editable-code

/*:
This allows us to write `sortByFirstName` in a much shorter and clearer way:

*/

//#-editable-code
let sortByFirstName: SortDescriptor<Person> = 
    sortDescriptor(key: { $0.first }, String.localizedCaseInsensitiveCompare)
people.sorted(by: sortByFirstName)
//#-end-editable-code

/*:
This `SortDescriptor` is just as expressive as its `NSSortDescriptor` variant,
but it's type safe, and it doesn't rely on runtime programming.

Currently, we can only use a single `SortDescriptor` function to sort arrays. If
you recall, we used the `NSArray.sortedArray(using:)` method to sort an array
with a number of comparison operators. We could easily add a similar method to
`Array`, or even to the `Sequence` protocol. However, we'd have to add it twice:
once for the mutating variant, and once for the non-mutating variant of `sort`.

We take a different approach so that we don't have to write more extensions.
Instead, we write a function that combines multiple sort descriptors into a
single sort descriptor. It works just like the `sortedArray(using:)` method:
first it tries the first descriptor and uses that comparison result. However, if
the result is equal, it uses the second descriptor, and so on, until we run out
of descriptors:

*/

//#-editable-code
func combine<Value>
    (sortDescriptors: [SortDescriptor<Value>]) -> SortDescriptor<Value> {
    return { lhs, rhs in
        for areInIncreasingOrder in sortDescriptors {
            if areInIncreasingOrder(lhs,rhs) { return true }
            if areInIncreasingOrder(rhs,lhs) { return false }
        }
        return false
    }
}
//#-end-editable-code

/*:
Using our new sort descriptors, we can now finally replicate the initial
example:

*/

//#-editable-code
let combined: SortDescriptor<Person> = combine(
    sortDescriptors: [sortByLastName,sortByFirstName,sortByYear]
)
people.sorted(by: combined)
//#-end-editable-code

/*:
We ended up with the same behavior and functionality as the Foundation version,
but it's safer and a lot more idiomatic in Swift. Because the Swift version
doesn't rely on runtime programming, the compiler can also optimize it much
better. Additionally, we can use it with structs or non-Objective-C objects.

This approach of using functions as data — storing them in arrays and building
those arrays at runtime — opens up a new level of dynamic behavior, and it's one
way in which a statically typed compile-time-oriented language like Swift can
still replicate some of the dynamic behavior of languages like Objective-C or
Ruby.

We also saw the usefulness of writing functions that combine other functions.
For example, our `combine(sortDescriptors:)` function took an array of sort
descriptors and combined them into a single sort descriptor. This is a very
powerful technique with many different applications.

Alternatively, we could even have written a custom operator to combine two sort
functions:

*/

//#-editable-code
infix operator <||> : LogicalDisjunctionPrecedence
func <||><A>(lhs: @escaping (A,A) -> Bool, rhs: @escaping (A,A) -> Bool)
    -> (A,A) -> Bool 
{
    return { x,y in
        if lhs(x,y) { return true }
        if lhs(y,x) { return false }
        
        // Otherwise, they're the same, so we check for the second condition
        if rhs(x,y) { return true }
        
        return false
    }
}
//#-end-editable-code

/*:
Most of the time, writing a custom operator is a bad idea. Custom operators are
often harder to read than functions are, because the name isn't explicit.
However, they can be very powerful when used sparingly. The operator above
allows us to rewrite our combined sort example, like so:

*/

//#-editable-code
let combinedAlt = sortByLastName <||> sortByFirstName <||> sortByYear
people.sorted(by: combinedAlt)
//#-end-editable-code

/*:
This reads very clearly and perhaps also expresses the code's intent more
succinctly than the alternative, but *only after* you (and every other reader of
the code) have ingrained the meaning of the operator. We prefer the
`combine(sortDescriptors:)` function over the custom operator. It's clearer at
the call site and ultimately makes the code more readable. Unless you're writing
highly domain-specific code, a custom operator is probably overkill.

The Foundation version still has one functional advantage over our version: it
can deal with optionals without having to write any more code. For example, if
we'd make the `last` property on `Person` an optional string, we wouldn't have
to change anything in the sorting code that uses `NSSortDescriptor`.

The function-based version requires some extra code. You know what comes next:
once again, we write a function that takes a function and returns a function. We
can take a regular comparing function such as `localizedCaseInsensitiveCompare`,
which works on two strings, and turn it into a function that takes two optional
strings. If both values are `nil`, they're equal. If the left-hand side is
`nil`, but the right-hand isn't, they're ascending, and the other way around.
Finally, if they're both non-`nil`, we can use the `compare` function to compare
them:

*/

//#-editable-code
func lift<A>(_ compare: @escaping (A) -> (A) -> ComparisonResult) -> (A?) -> (A?)
    -> ComparisonResult 
{
    return { lhs in { rhs in
        switch (lhs, rhs) {
        case (nil, nil): return .orderedSame
        case (nil, _): return .orderedAscending
        case (_, nil): return .orderedDescending
        case let (l?, r?): return compare(l)(r)
        default: fatalError() // Impossible case
        }
    } }
}
//#-end-editable-code

/*:
This allows us to "lift" a regular comparison function into the domain of
optionals, and it can be used together with our `sortDescriptor` function. If
you recall the `files` array from before, sorting it by `fileExtension` got
really ugly because we had to deal with optionals. However, with our new `lift`
function, it's very clean again:

*/

//#-editable-code
let lcic = lift(String.localizedCaseInsensitiveCompare)
let result = files.sorted(by: sortDescriptor(key: { $0.fileExtension }, lcic))
result
//#-end-editable-code

/*:
> We can write a similar version of `lift` for functions that return a `Bool`.
> As we saw in the optionals chapter, the standard library no longer provides
> comparison operators like `>` for optionals. They were removed because using
> them can lead to surprising results if you're not careful. A boolean variant
> of `lift` allows you to easily take an existing operator and make it work for
> optionals when you need the functionality.

One drawback of the function-based approach is that functions are opaque. We can
take an `NSSortDescriptor` and print it to the console, and we get some
information about the sort descriptor: the key path, the selector name, and the
sort order. Our function-based approach can't do this. For sort descriptors,
this isn't a problem in practice. If it's important to have that information, we
could wrap the functions in a struct or class and store additional debug
information.

This approach has also given us a clean separation between the sorting method
and the comparison method. The algorithm that Swift's sort uses is a hybrid of
multiple sorting algorithms — as of this writing, it's an
[introsort](https://en.wikipedia.org/wiki/Introsort) (which is itself a hybrid
of a quicksort and a heapsort), but it switches to an [insertion
sort](https://en.wikipedia.org/wiki/Insertion_sort) for small collections to
avoid the upfront startup cost of the more complex sort algorithms.

Introsort isn't a
"[stable](https://en.wikipedia.org/wiki/Category:Stable_sorts)" sort. That is,
it doesn't necessarily maintain relative ordering of values that are otherwise
equal according to the comparison function. But if you implemented a stable
sort, the separation of the sort method from the comparison would allow you to
swap it in easily:

``` swift-example
people.stablySorted(by: combine(
    sortDescriptors: [sortByLastName, sortByFirstName, sortByYear]
))
```

*/
