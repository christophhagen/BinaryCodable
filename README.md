# BinaryCodable

This package provides convenient encoding and decoding to/from binary data for Swift's `Codable` types.

## Use cases

There are only few encoders and decoders available for Swift's Codable format, and Apple provides a [JSONEncoder](https://developer.apple.com/documentation/foundation/jsonencoder) and a [PropertyListEncoder](https://developer.apple.com/documentation/foundation/propertylistencoder) for basic encoding. While these can cover some use cases (especially when interacting with Web Content through JSON), they lack efficiency when designing APIs within an ecosystem. JSON, for example, is notoriously inefficient when it comes to binary data.

One very popular alternative for binary data are Google's [Protocol Buffers](https://developers.google.com/protocol-buffers), which offer broad support across different platforms and programming languages. But they don't support Swift's `Codable` protocol, and thus require manual message definitions, the Protobuf compiler, and a lot of copying between data structures during encoding and decoding.

So if you're looking for a decently efficient binary encoder in a pure Swift project, then `BinaryCodable` may be right for you. Simply make your `struct`s (or classes!) conform to `Codable`, and `BinaryCodable` does the rest!

## Installation

### Swift Package Manager

Simply include in your `Package.swift`:
```swift
dependencies: [
    .package(
        name: "ProtobufCodable", 
        url: "https://github.com/christophhagen/ProtobufCodable", 
        from: "0.4.0")
],
targets: [
    .target(name: "MyTarget", dependencies: ["ProtobufCodable"])
]
```

### Xcode project

Select your `Project`, navigate to the `Package Dependencies` tab, and add `https://github.com/christophhagen/ProtobufCodable` using the `+` button.

## Usage

Let's assume a message definition: 

```swift
struct Message: Codable {

    var sender: String
    
    var isRead: Bool
    
    var unreadCount: Int
}
```

Simply import the module when you need to encode or decode a message:

```swift
import BinaryCodable
```

## Encoding

Construct an encoder when converting instances to binary data, and feed the message(s) into it:

```swift
let message = Message(...)

let encoder = BinaryEncoder()
let data = try encoder.encode(message)
```

It's also possible to encode single values, arrays, optionals, sets, enums, dictionaries, and more, so long as they conform to `Codable`.

## Decoding

Decoding instances from binary data works much the same way:

```swift
let decoder = BinaryDecoder()
let message = decoder.decode(Message.self, from: data)
```

Alternatively, the type can be inferred:

```swift
let message: Message = decoder.decode(from: data)
```

## Coding Keys

The `Codable` protocol uses [CodingKey](https://developer.apple.com/documentation/swift/codingkey) definitions to identify properties of instances. By default, coding keys are generated using the string values of the property names.

Similar to JSON encoding, `BinaryCodable` can embed the property names in the encoded data.

Unlike JSON (which is human-readable), the binary representation produced by `BinaryCodable` is intended for cases when efficient encoding is important. `Codable` allows the use of integer keys for each property by adding an enum conforming to the `CodingKey` protocol to the `Codable` type:

```swift
struct Message: Codable {

    enum CodingKeys: Int, CodingKey {
        case sender = 1
        case isRead = 2
        case unreadCount = 3
    }

    var sender: String
    
    var isRead: Bool
    
    var unreadCount: Int
}
```
The enum must have a raw value of either `Int` or `String`, and the cases must match the property names within the type (it is possible to omit keys for properties which should not be encoded).

Using integer keys can significantly decrease the binary size, especially for long property names. Additionally, integer keys can be useful when intending to store the binary data persistently. Changes to property names can be performed in the code without breaking the decoding of older data (although this can also be achieved with custom `String` keys).

## Binary data structure

**Note** The binary format is optimized for size, but does not go all-out to create the smallest binary sizes possible. If this is your goal, then simply using `Codable` with it's key-value approach will not be the best solution. An unkeyed format optimized for the actually encoded data will be more suitable. But if you're really looking into this kind of efficiency, then you probably know this already.

The encoding format used by `BinaryCodable` is similar to Google's [Protocol Buffers](https://developers.google.com/protocol-buffers) in some aspects, but provides much more flexibility regarding the different types which can be encoded, including the ability to encode `Optional`, `Set`, multidimensional arrays, and more.

### Integer encoding

Integers are encoded with different strategies depending on their size. Smaller types, like `UInt8`, `Int8`, `UInt16`, and `Int16` are encoded using their binary representations in little-endian format. 

Larger integers, like `UInt32`, `Int32`, `UInt64`, `Int64`, `Int`, and `UInt` are (by default) encoded using variable length encoding, similar to [Protobuf Base128 Varints](https://developers.google.com/protocol-buffers/docs/encoding#varints). This means that smaller values are encoded as shorter binary representations, which is useful if integer values are mostly small.
**Note** The `Varint` implementation is not equivalent the same, since `BinaryCodable` uses the last byte of a large integer directly, and thus encodes `Int.max` with 9 Byte instead of 10.

#### Signed integers

Varint encoding is efficient for small numbers, but doesn't work efficiently with negative values. `BinaryCodable` offers `SignedValue` wrappers that can be applied to `Int`, `Int32` and `Int64` properties to increase the efficiency for negative values as well, similar to Protobufs `sint32` and `sint64` scalar types.

Whenever your integers are expected to have small magnitudes with negative numbers, then you should apply the wrapper:
 ```swift
 struct MyStruct: Codable {
 
     /// Efficiently encodes small negative numbers
     @SignedValue 
     var signedInteger: Int32
 }
 ```
 
 This declaration enforces ZigZag-Encoding of the integers, as explained [here](https://developers.google.com/protocol-buffers/docs/encoding#signed-ints).
 
#### Fixed-width integers

While varints are efficient for small numbers, their encoding introduces a storage and computation penalty when the integers are often large, e.g. for random numbers. `BinaryCodable` provides the `FixedWidth` wrapper, which forces integers to be encoded using their little-endian binary representations. This means that e.g. an `Int32` is always encoded as 4 byte (instead of 1-5 bytes using Varint encoding).

 Use the property wrapped within a `Codable` definition to enforce fixed-width encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Always encoded as 4 bytes
     @FixedWidth 
     var largeInteger: Int32
 }
 ```
 
 The `FixedWidth` wrapper is available to all `Varint` types: `Int`, `UInt`, `Int32`, `UInt32`, `Int64`, and `UInt64`.

### Floating-point types

`Float` and `Double` values are encoded using their binary representations in little-endian format.

### Strings

Swift `String` values are encoded using their `UTF-8` representations. If a string can't be encoded this way, then encoding fails.

### Booleans

`Bool` values are always encoded as a single byte, using `1` for `true`, and `0` for `false`.

### Arrays

Arrays (and other sequences) are encoded by converting each item to binary data, and concatenating the results. Elements with variable length (like `String`) are prepended with their length encoded as a [Varint](#integer-encoding). Each encoded array has at least one byte prepended to it, in order to support optional values.

#### Arrays of Optionals

It is possible to encode arrays where the elements are `Optional`, e.g. `[Bool?]`. Due to constraints regarding Apple's implementation of `Encoder` and `Decoder`, it is not consistently possible to infer if optionals are present in unkeyed containers. `BinaryCodable` therefore encodes optionals using a different strategy: Each array binary representation is prepended with a "nil index set". It first consists of the number of `nil` elements in the sequence, encoded as a `Varint`. Then follow the indices in the array where `nil` values are present, each encoded as a `Varint`. The decoder can then first parse this `nil` set, and return the appropriate value for each position where a `nil` value is encoded. This approach is fairly efficient while only few `nil` values are encoded, or while the sequence doesn't contain a large number of elements. For arrays that don't contain optionals, only a single byte (`0`) is prepended to the binary representation, to signal that there are no `nil` indices in the sequence.

### Structs

Structs are encoded using `Codable`'s `KeyedEncodingContainer`, which uses `String` or `Int` coding keys to distinguish the properties of the types. By default, Swift uses the property names as `String` keys, which are used to encode each property as a key-value pair on the wire. The first value is a `Varint`, which contains the length of the string key, plus additional information about the data associated with the key. The bits 0-2 are used to signal the size value, and bit 3 of the `Varint` indicates whether the key is a string key (`0` = string, `1` = int). The following data types are possible: 

| Data type | Raw value | Swift types | Description |
|    :--    |    :--    |     :--     |     :--     |
`variableLengthInteger` | `0` | `Int`, `Int32`, `Int64`,  `UInt`, `UInt32`, `UInt64` | A Base128 `Varint` using 1-9 bytes of data
`byte` | `1` | `Bool`, `UInt8`, `Int8` | A single byte storing a number or boolean
`twoBytes` | `2` | `Int16`, `UInt16` | Two bytes storing an integer using little-endian format
`variableLength` | `3` | `String`, `Struct`, ... | The length of the data encoded as a `Varint` followed by `length` bytes
`fourBytes` | `4` | `Float`, `FixedWidth<Int32>`, `FixedWidth<UInt32>` | A 32-bit float or integer in little-endian encoding.
`eightBytes` | `5` | `Double`, `FixedWidth<Int64>`, `FixedWidth<Int>`, `FixedWidth<UInt64>`, `FixedWidth<UInt>` | A 64-bit float or integer in little-endian encoding.

With the four lower bits occupied by the data type and the string key indicator, the remaining bits are left to encode the length of the string key.

For example, a property named `xyz`  of type `UInt8` with value `123` would be encoded to the following:

| Byte 0 | Byte 1 | Byte 2 | Byte 3 | Byte 4 | 
|  :--   |  :--   |  :--   |  :--   |  :--   |
| `0` `011` `1` `001` | `01111000` | `01111001` | `01111010` | `01111011` |
| Length `3`, `String` key, Data type `byte` | `x` | `y` | `z` | `123` |

#### Integer keys

The Swift `Codable` framework also provides the ability to specify integer keys for properties, which can significantly reduce the binary size. Integer keys can be assigned to properties by implementing custom `CodingKeys` for a type:
```swift
struct MyCodable: Codable {

    let xyz: UInt8
    
    enum CodingKeys: Int, CodingKey {
        case xyz = 2
    }
}
```
Integer coding keys are encoded as `Varint` instead of the `String` key length. This results in the following encoding for the same example as before:

| Byte 0 | Byte 1 | 
|  :--   |  :--   |
| `0` `010` `0` `001` | `01111011` |
| Integer key `2`, `Int` key, Data type `byte` | `123` |

Evidently this is a significant improvement, especially for long property names. Note that while it is possible to specify any integer as the key (between 2^59 and -2^59), small, positive integers are the most efficient.

#### Optional properties
