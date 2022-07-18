# BinaryCodable

This package provides convenient encoding and decoding to/from binary data for all Swift `Codable` types. It also provides limited cross-compatibility to [Google Protocol Buffers](https://developers.google.com/protocol-buffers).

## Use cases

There are only few encoders and decoders available for Swift's Codable format, and Apple provides a [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) and a [PropertyListEncoder](https://developer.apple.com/documentation/foundation/propertylistencoder) for basic encoding. While these can cover some use cases (especially when interacting with Web Content through JSON), they lack encoding efficiency when designing APIs within an ecosystem. JSON, for example, is notoriously inefficient when it comes to binary data.

One very popular alternative for binary data are Google's [Protocol Buffers](https://developers.google.com/protocol-buffers), which offer broad support across different platforms and programming languages. But they don't support Swift's `Codable` protocol, and thus require manual message definitions, the Protobuf compiler, and a lot of copying between data structures during encoding and decoding.

So if you're looking for a decently efficient binary encoder in a pure Swift project, then `BinaryCodable` may be right for you. Simply make your `struct`s (or classes!) conform to `Codable`, and `BinaryCodable` does the rest!

The [message format](#binary-format) is similar to that of `Protocol Buffers` (with some additions to support more types). It is possible to create [limited compatibility](#protocol-buffer-compatibility) between the two formats to exchange data with systems that don't support Swift.

## Installation

### Swift Package Manager

Simply include in your `Package.swift`:
```swift
dependencies: [
    .package(
        name: "BinaryCodable", 
        url: "https://github.com/christophhagen/BinaryCodable", 
        from: "1.0.0")
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

### Errors

It is possible for both encoding and decoding to fail. 
All possible errors occuring during encoding produce `BinaryEncodingError` errors, while unsuccessful decoding produces `BinaryDecodingError`s. 
Both are enums with several cases describing the nature of the error. 
See the documentation of the types to learn more about the different error conditions.

### Coding Keys

The `Codable` protocol uses [`CodingKey`](https://developer.apple.com/documentation/swift/codingkey) definitions to identify properties of instances. By default, coding keys are generated using the string values of the property names.

Similar to JSON encoding, `BinaryCodable` can embed the property names in the encoded data.

Unlike JSON (which is human-readable), the binary representation produced by `BinaryCodable` is intended for cases when efficient encoding is important. `Codable` allows the use of integer keys for each property, which significantly increases encoding efficiency. You can specify integer keys by adding an `Int` enum conforming to the `CodingKey` protocol to the `Codable` type:

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

Using integer keys can significantly decrease the binary size, especially for long property names. Additionally, integer keys can be useful when intending to store the binary data persistently. Changes to property names can be performed in the code without breaking the decoding of older data (although this can also be achieved with custom `String` keys).

Notes: 
- Small, positive integer keys produce the smallest binary sizes.
- The `0` integer key shouldn't be used, since it is also used internally when encoding `super`.
- Negative values for integer keys are **not** recommended (but possible). Since the keys are encoded as `Varint`, they are very inefficient for negative numbers.
- The allowed range for integer keys is from `-576460752303423488` (`-2^59`, inclusive) to `576460752303423487` (`2^59-1`, inclusive). Values outside of these bounds will cause a `fatalError` crash.

### Property wrappers

#### Fixed size integers

While varints are efficient for small numbers, their encoding introduces a storage and computation penalty when the integers are often large, e.g. for random numbers. `BinaryCodable` provides the `FixedSize` wrapper, which forces integers to be encoded using their little-endian binary representations. This means that e.g. an `Int32` is always encoded as 4 byte (instead of 1-5 bytes using Varint encoding). This makes 32-bit `FixedSize` types more efficient than `Varint` if values are often larger than `2^28` (`2^56` for 64-bit types).

 Use the property wrapper within a `Codable` definition to enforce fixed-width encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Always encoded as 4 bytes
     @FixedSize 
     var largeInteger: Int32
 }
 ```
 
 The `FixedSize` wrapper is available to all `Varint` types: `Int`, `UInt`, `Int32`, `UInt32`, `Int64`, and `UInt64`.
 
 #### Other property wrappers
 
 There is an additional `SignedValue` wrapper, which is only useful when encoding in [protobuf-compatible format](ProtobufSupport.md#signed-integers).

### Options

The `BinaryEncoder` provides the `sortKeysDuringEncoding` option, which forces fields in "keyed" containers, such as `struct` properties (and some dictionaries), to be sorted in the binary data. This sorting is done by using either the [integer keys](#coding-keys) (if defined), or the property names. Dictionaries with `Int` or `String` keys are also sorted. 

Sorting the binary data does not influence decoding, but introduces a computation penalty during encoding. It should therefore only be used if the binary data must be consistent across multiple invocations.

**Note:** The `sortKeysDuringEncoding` option does not guarantee deterministic binary data, and should be used with care. 

### Protocol Buffer compatibility

Achieving Protocol Buffer compatibility is described in [ProtobufSupport.md](ProtobufSupport.md).

## Binary format

To learn more about the encoding format, see [BinaryFormat.md](BinaryFormat.md).

## Tests

The library comes with an extensive test suite, which checks that encoding works correctly for many cases. These tests can be executed using ```swift test``` from the package root, or when opening the package using Xcode.

## License

MIT. See [License.md](License.md)

## Roadmap

### Generate protobuf definitions

It should be possible to generate a string containing a working Protobuf definition for any type that is determined to be Protobuf compatible.

### Speed

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
