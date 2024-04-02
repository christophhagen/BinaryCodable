<p align="center">
    <img src="assets/logo.png" width="500" max-width="90%" alt="BinaryCodable" />
</p>
<p align="center">
    <img src="assets/swift.svg" />
    <img src="assets/platforms.svg" />
    <a href="https://github.com/christophhagen/BinaryCodable/actions/workflows/tests.yml">
        <img src="https://github.com/christophhagen/BinaryCodable/actions/workflows/tests.yml/badge.svg" />
    </a>
    <a href="https://christophhagen.de/docs/BinaryCodable/index.html">
        <img src="docs/badge.svg" />
    </a>
</p>

This package provides convenient encoding and decoding to/from binary data for all Swift `Codable` types. 

## Use cases

There are only few encoders and decoders available for Swift's Codable format, and Apple provides a [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) and a [PropertyListEncoder](https://developer.apple.com/documentation/foundation/propertylistencoder) for basic encoding. While these can cover some use cases (especially when interacting with Web Content through JSON), they lack encoding efficiency when designing APIs within an ecosystem. JSON, for example, is notoriously inefficient when it comes to binary data.

One very popular alternative for binary data are Google's [Protocol Buffers](https://developers.google.com/protocol-buffers), which offer broad support across different platforms and programming languages. But they don't support Swift's `Codable` protocol, and thus require manual message definitions, the Protobuf compiler, and a lot of copying between data structures during encoding and decoding.

So if you're looking for a decently efficient binary encoder in a pure Swift project, then `BinaryCodable` may be right for you. Simply make your `struct`s (or classes!) conform to `Codable`, and `BinaryCodable` does the rest!

### Alternatives

#### [Protocol Buffers](https://developers.google.com/protocol-buffers)
Already mentioned above

#### [CBORCoding](https://github.com/SomeRandomiOSDev/CBORCoding)
If you're looking for a `Codable`-compatible alternative which is also available on other platforms, with a well-defined [spec](https://cbor.io). It appears to have nearly the same encoding efficiency as `BinaryCodable`. 

#### [PotentCodables](https://github.com/outfoxx/PotentCodables)
Also offers CBOR encoding, plus a bunch of other things related to `Codable`.

#### [Swift BSON](https://github.com/mongodb/swift-bson)
Encoding according to the [BSON specification](https://bsonspec.org). Less efficient binary represenation than Protocol Buffers and `BinaryCodable`, but mature. Used for MongoDB.

## Installation

### Swift Package Manager

Simply include in your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/christophhagen/BinaryCodable", from: "3.0.0")
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "BinaryCodable", package: "BinaryCodable")
    ])
]
```

### Xcode project

Select your `Project`, navigate to the `Package Dependencies` tab, and add `https://github.com/christophhagen/BinaryCodable` using the `+` button.

## Usage

Let's assume a message definition: 

```swift
struct Message: Codable {

    var sender: String
    
    var isRead: Bool
    
    var unreadCount: Int
}
```

Simply import the module where you need to encode or decode a message:

```swift
import BinaryCodable
```

### Encoding

Construct an encoder when converting instances to binary data, and feed the message(s) into it:

```swift
let message: Message = ...

let encoder = BinaryEncoder()
let data = try encoder.encode(message)
```

It's also possible to encode single values, arrays, optionals, sets, enums, dictionaries, and more, so long as they conform to `Codable`.

### Decoding

Decoding instances from binary data works much the same way:

```swift
let decoder = BinaryDecoder()
let message = try decoder.decode(Message.self, from: data)
```

Alternatively, the type can be inferred:

```swift
let message: Message = try decoder.decode(from: data)
```

### Custom encoding and decoding

`BinaryCodable` supports the use of custom encoding and decoding routines by implementing `encode(to:)` and `init(from:)`.

There is only one aspect that's handled differently than the `Codable` documentation specifies, which is the explicit encoding of `nil` in keyed containers.
Calling `encodeNil(forKey:)` on a keyed container has no effect, there is no explicit `nil` value encoded for the key.
This results in the `contains()` function during decoding returning `false` for the key.
This is different to e.g. JSON, where calling `encodeNil(forKey:)` would cause the following encoding:

```json
{ 
    "myProperty" : nil
}
```

The implementation of `encodeNil(forKey:)` and `decodeNil(forKey:)` handles this case differently, because the alternatives are not optimal:
It would be possible to explicitly encode `nil` for a key, but this would cause problems with double optionals in structs (e.g. Int??), which could no longer distinguish between `.some(nil)` and `nil`.
To fix this issue, an additional `nil` indicator would be needed for **all** values in keyed containers, which would decrease the efficiency of the binary format. 
That doesn't seem reasonable just to support a rarely used feature, since `encodeNil(forKey:)` is never called for automatically synthesized Codable conformances.

The recommendation therefore is to use `encodeIfPresent(_, forKey:)` and `decodeIfPresent(_, forKey:)`.
Another option would be to use a double optional, since this is basically the information `encodeNil` provides: `nil`, if the key is not present, `.some(nil)`, if the key is present with `nil`, and `value`, if the key is present with a value.

### Errors

It's possible for both encoding and decoding to fail. 
Encoding can produce `EncodingError` errors, while unsuccessful decoding produces `DecodingError`s. 
Both are the default Errors provided by Swift, supplied with additional information describing the nature of the error. 
See the documentation of the types to learn more about the different error conditions.

#### Handling corrupted data

The [binary format](BinaryFormat.md) provides no provisions to detect data corruption, and various errors can occur as the result of added, changed, or missing bytes and bits. 
Additional external measures (checksums, error-correcting codes, ...) should be applied if there is an increased risk of data corruption.

As an example, consider the simple encoding of a `String` inside a `struct`, which consists of a `key` followed by the length of the string in bytes, and the string content.
The length of the string is encoded using variable-length encoding, so a single bit flip (in the MSB of the length byte) could result in a very large `length` being decoded, causing the decoder to wait for a very large number of bytes to decode the string.
This simple error would cause much data to be skipped, potentially corrupting the data stream indefinitely.
At the same time, it is not possible to determine *with certainty* where the error occured, making error recovery difficult without additional information about boundaries between elements.

The decoding errors provided by the library are therefore only hints about errors likely occuring from non-conformance to the binary format or version incompatibility, which are not necessarily the *true* causes of the failures when data corruption is present.

### Coding Keys

The `Codable` protocol uses [`CodingKey`](https://developer.apple.com/documentation/swift/codingkey) definitions to identify properties of instances. 
By default, coding keys are generated using the string values of the property names.

Similar to JSON encoding, `BinaryCodable` can embed the property names in the encoded data.

Unlike JSON (which is human-readable), the binary representation produced by `BinaryCodable` is intended for cases when efficient encoding is important. 
`Codable` allows the use of integer keys for each property, which significantly increases encoding efficiency. 
You can specify integer keys by adding an `Int` enum conforming to the `CodingKey` protocol to the `Codable` type:

```swift
struct Message: Codable {

    var sender: String
    
    var isRead: Bool
    
    var unreadCount: Int
    
    // Assign an integer to each property
    enum CodingKeys: Int, CodingKey {
        case sender = 1
        case isRead = 2
        case unreadCount = 3
    }
}
```
The enum must have a raw value of either `Int` or `String`, and the cases must match the property names within the type (it is possible to omit keys for properties which should not be encoded).

Using integer keys can significantly decrease the binary size, especially for long property names. 
Additionally, integer keys can be useful when intending to store the binary data persistently. 
Changes to property names can be performed in the code without breaking the decoding of older data (although this can also be achieved with custom `String` keys).

Notes: 
- Small, positive integer keys produce the smallest binary sizes.
- The `0` integer key shouldn't be used, since it is also used internally when encoding `super`.
- Negative values for integer keys are **not** rsupported.
- The allowed range for integer keys is from `0` (inclusive) to `Int64.max` (inclusive).

### Property wrappers

#### Fixed size integers

While varints are efficient for small numbers, their encoding introduces a storage and computation penalty when the integers are often large, e.g. for random numbers. 
`BinaryCodable` provides the `FixedSize` wrapper, which forces integers to be encoded using their little-endian binary representations. 
This means that e.g. an `Int32` is always encoded as 4 byte (instead of 1-5 bytes using Varint encoding). 
This makes 32-bit `FixedSize` types more efficient than `Varint` if values are often larger than `2^28` (`2^56` for 64-bit types).

 Use the property wrapper within a `Codable` definition to enforce fixed-width encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Always encoded as 4 bytes
     @FixedSize 
     var largeInteger: Int32
 }
 ```
 
 The `FixedSize` wrapper is available to all `Varint` types: `Int`, `UInt`, `Int32`, `UInt32`, `Int64`, and `UInt64`.

### Options

#### Sorting keys

The `BinaryEncoder` provides the `sortKeysDuringEncoding` option, which forces fields in "keyed" containers, such as `struct` properties (and some dictionaries), to be sorted in the binary data. 
This sorting is done by using either the [integer keys](#coding-keys) (if defined), or the property names. 
Dictionaries with `Int` or `String` keys are also sorted. 

Sorting the binary data does not influence decoding, but introduces a computation penalty during encoding. 
It should therefore only be used if the binary data must be consistent across multiple invocations.

**Note:** The `sortKeysDuringEncoding` option does **not** guarantee deterministic binary data, and should be used with care.
Elements of any non-ordered types (Sets, Dictionaries) will appear in random order in the binary data.

### Stream encoding and decoding

The library provides the option to perform encoding and decoding of continuous streams, such as when writing sequences of elements to a file, or when transmitting data over a network.
This functionality can be used through `BinaryStreamEncoder` and `BinaryStreamDecoder`, causing the encoder to embed additional information into the data to allow continuous decoding (mostly length information).
Encoding and decoding is always done with sequences of one specific type, since multiple types in one stream could not be distinguished from one another.

Encoding of a stream works similarly to normal encoding:

```swift
let encoder = BinaryStreamEncoder<Int>()
let chunk1 = try encoder.encode(1)
let chunk2 = try encoder.encode(contentsOf: [2,3])
...

let data = chunk1 + chunk2 + ...
```

Decoding of the individual chunks, with the decoder returning all elements which can be decoded using the currently available data.

```swift
let decoder = BinaryStreamDecoder<Int>()
let decoded1 = try decoder.decode(chunk1)
print(decoded1) // [1]

let decoded2 = try decoder.decode(chunk2)
print(decoded2) // [2,3]
```

The decoder has an internal buffer, so incomplete data can be inserted into the decoder as it becomes available. The output of `decode(_ data:)` will be empty until the next complete element is processed.

### File encoding and decoding 

Writing data streams to files is a common use case, so the library also provides wrappers around `BinaryStreamEncoder` and `BinaryStreamDecoder` to perform these tasks.
The `BinaryFileEncoder` can be used to sequentially write elements to a file:

```swift
let encoder = BinaryFileEncoder<DataElement>(fileAt: url)
try encoder.write(element1)
try encoder.write(element2)
...
try encoder.close() // Close the file
```

Elements will always be appended to the end of file, so existing files can be updated with additional data.

Decoding works in a similar way, except with a callback to handle each element as it is decoded:
```swift
let decoder = BinaryFileDecoder<DataElement>(fileAt: url)
try decoder.read { element in
    // Process each element
}
```

There is also the possibility to read all elements at once using `readAll()`, or to read only one element at a time (`readElement()`).

## Binary format

To learn more about the encoding format, see [BinaryFormat.md](BinaryFormat.md).

## Legacy versions and migration

Version 3 of `BinaryCodable` has significantly changed the binary format, which means that the two versions are **not** cross-compatible.
The [format](BinaryFormat.md) was changed to provide support for all `Codable` features, which was not possible with the previous format, that was adapted from [Protocol Buffers](https://developers.google.com/protocol-buffers).
The redesign of the library also reduced code complexity and size, which lead to some speed improvements and greater reliability.

The support for interoperability with [Protocol Buffers](https://developers.google.com/protocol-buffers) was also dropped, since the binary formats are no longer similar.
The functionality was extracted to a separate library called [ProtobufCodable](https://github.com/christophhagen/ProtobufCodable).

### Migrating from 2.x to 3.0

To convert data from the [legacy format](LegacyFormat) to the new version, the data has to be decoded with version 2 and re-encoded with version 3.
The Swift Package Manager currently doesn't allow to include the same dependency twice (with different versions), so the legacy version has been stripped down to the essentials and is provided as the stand-alone package [LegacyBinaryCodable](https://christophhagen.de/LegacyBinaryCodable).
It only allows decoding, and can be integrated as a separate dependency:

```swift
dependencies: [
    .package(url: "https://github.com/christophhagen/BinaryCodable", from: "3.0.0"),
        .package(url: "https://github.com/christophhagen/LegacyBinaryCodable", from: "2.0.0"),
    
],
targets: [
    .target(name: "MyTarget", dependencies: [
        .product(name: "BinaryCodable", package: "BinaryCodable"),
        .product(name: "LegacyBinaryCodable", package: "LegacyBinaryCodable")
    ])
]
```

In the code, you can then decode and re-encode:

```swift
import BinaryCodable
import LegacyBinaryCodable

func reencode<T>(data: Data, as type: T.Type) throws -> Data where T: Codable {
    let decoder = LegacyBinaryDecoder()
    let value = try decoder.decode(T.self, from data: Data)
    let encoder = BinaryEncoder()
    return try encoder.encode(value)
}
```

## Tests

The library comes with an extensive test suite, which checks that encoding works correctly for many cases. 
These tests can be executed using ```swift test``` from the package root, or when opening the package using Xcode.

## License

MIT. See [License.md](License.md)

## Roadmap

### Additional tests

While the test suite covers many cases, there is no complete code coverage.
Especially the bahaviour in error conditions can use additional testing to ensure that there are no edge cases where the program crashes, or does some other weird thing.

### Speed

One option could be to use a common data storage during encoding and decoding, so that the individual containers can be converted to `struct`s to make them more lightweight. It may also be possible to prevent some unnecessary data copying.

Increasing the speed of the encoding and decoding process is not a huge priority at the moment. 
If you have any pointers on how to improve the performance further, feel free to contribute.

## Contributing

Users of the library are encouraged to contribute to this repository.

### Feature suggestions

Please file an issue with a description of the feature you're missing. Check other open and closed issues for similar suggestions and comment on them before creating a new issue.

### Bug reporting

File an issue with a clear description of the problem. Please include message definitions and other data where possible so that the error can be reproduced.

### Documentation

If you would like to extend the documentation of this library, or translate the documentation into other languages, please also open an issue, and I'll contact you for further discussions.
