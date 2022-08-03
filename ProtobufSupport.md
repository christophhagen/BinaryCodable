# Protocol Buffer Compatibility

`BinaryCodable` provides limited compatibility to [Google Protocol Buffers](https://developers.google.com/protocol-buffers). Certain Swift types can be encoded to protobuf compatible binary data, and vice versa. The standard [binary format](BinaryFormat.md) is similar to protobuf, but includes some deviations to support all Swift types and features. There are additional `ProtobufEncoder` and `ProtobufDecoder` types which change the encoding format to be protobuf-compatible, at the expense of errors for unsupported features.

For a description of the Protocol Buffer format, see the [official documentation](https://developers.google.com/protocol-buffers).

**Important notes** 
- Advanced protobuf features like message concatenation are not supported.
- Unsupported features of Protobuf *may* cause the encoding to fail with a `ProtobufEncodingError`. Interoperability should be thoroughly checked through testing.

## Usage

The conversion process is equivalent to the `BinaryEncoder` and `BinaryDecoder` types.

```swift
import BinaryCodable
```

### Encoding

Construct an encoder when converting instances to binary data, and feed the message(s) into it:

```swift
let message: Message = ...

let encoder = ProtobufEncoder()
let data = try encoder.encode(message)
```

### Decoding

Decoding instances from binary data works much the same way:

```swift
let decoder = ProtobufDecoder()
let message = try decoder.decode(Message.self, from: data)
```

Alternatively, the type can be inferred:

```swift
let message: Message = try decoder.decode(from: data)
```

### Errors

It is possible for both encoding and decoding to fail. 
All possible errors occuring during encoding produce `BinaryEncodingError` or `ProtobufEncodingError` errors, while unsuccessful decoding produces `BinaryDecodingError` or `ProtobufDecodingError`. 
All are enums with several cases describing the nature of the error. 
See the documentation of the types to learn more about the different error conditions.

## Message definition

Protobuf organizes data into messages, which are structures with keyed fields. Compatible Swift types must be similar, so either `struct` or `class`. Simple types like `Int` or `Bool` are not supported on the root level, and neither are `Dictionary`, `Array` or `enum`. It's best to think of the proto definitions and construct Swift types in the same way. Let's look at an example from the [Protocol Buffer documentation](https://developers.google.com/protocol-buffers/docs/proto3#simple):

```proto
message SearchRequest {
    string query = 1;
    int32 page_number = 2;
    int32 result_per_page = 3;
}
```

The corresponding Swift definition would be:

```swift
struct SearchRequest: Codable {

    var query: String
    
    var pageNumber: Int32
    
    var resultPerPage: Int32
    
    enum CodingKeys: Int, CodingKey {
        case query = 1
        case pageNumber = 2
        case resultPerPage = 3
    }
}
```

The general structure of the messages is very similar, with the proto field numbers specified as integer coding keys.

### Assigning integer keys

The assignment of integer keys follow the same [rules](https://developers.google.com/protocol-buffers/docs/proto3#assigning_field_numbers) as for field numbers, just written out as an `enum` with `RawValue == Int` on the type conforming to `CodingKey`. The smallest field number you can specify is `1`, and the largest is `2^29 - 1`, or `536,870,911`. Codable types without (or with invalid) integer keys can't be encoded using `ProtobufEncoder` and will throw an error.

### Scalar value types

There are several [scalar types](https://developers.google.com/protocol-buffers/docs/proto3#scalar) defined for Protocol Buffers, which are the basic building blocks of messages. `BinaryCodable` provides Swift equivalents for each of them:

| Protobuf primitive | Swift equivalent       | Comment                                                               |
| :----------------- | :--------------------- | :-------------------------------------------------------------------- |
| `double`           | `Double`               | Always 8 byte                                                         |
| `float`            | `Float`                | Always 4 byte                                                         |
| `int32`            | `Int32`                | Uses variable-length encoding                                         |
| `int64`            | `Int64`                | Uses variable-length encoding                                         |
| `uint32`           | `UInt32`               | Uses variable-length encoding                                         |
| `uint64`           | `UInt64`               | Uses variable-length encoding                                         |
| `sint32`           | `SignedInteger<Int32>` | Uses ZigZag encoding, see [`SignedInteger` wrapper](#signed-integers) |
| `sint64`           | `SignedInteger<Int64>` | Uses ZigZag encoding, see [`SignedInteger` wrapper](#signed-integers) |
| `fixed32`          | `FixedSize<UInt32>`    | See [`FixedSize` wrapper](#fixed-size-integers)                       |
| `fixed64`          | `FixedSize<UInt64>`    | See [`FixedSize` wrapper](#fixed-size-integers)                       |
| `sfixed32`         | `FixedSize<Int32>`     | See [`FixedSize` wrapper](#fixed-size-integers)                       |
| `sfixed64`         | `FixedSize<Int64>`     | See [`FixedSize` wrapper](#fixed-size-integers)                       |
| `bool`             | `Bool`                 | Always 1 byte                                                         |
| `string`           | `String`               | Encoded using UTF-8                                                   |
| `bytes`            | `Data`                 | Encoded as-is                                                         |
| `message`          | `struct`               | Nested messages are also supported.                                   |
| `repeated`         | `Array`                | Scalar values must always be `packed` (the proto3 default)            |
| `enum`             | `Enum`                 | See [Enums](#enums)                                                   |
| `oneof`            | `Enum`                 | See [OneOf Definition](#oneof)                                        |

The Swift types `Int8`, `UInt8`, `Int16`, and `UInt16` are **not** supported, and will result in an error.

Note: `Int` and `UInt` values are always encoded as 64-bit numbers, despite the fact that they might be 32-bit values on some systems. Decoding a 64-bit value on a 32-bit system will result in an error.

### Property wrappers

The Protocol Buffer format provides several different encoding strategies for integers to minimize the binary size depending on the encoded values. By default, all integers are encoded using [Base 128 Varints](https://developers.google.com/protocol-buffers/docs/encoding#varints), but this can be changed using Swift `PropertyWrappers`. The following encoding options exist:

| Swift type | [Varint encoding](https://developers.google.com/protocol-buffers/docs/encoding#varints) | [ZigZag Encoding](https://developers.google.com/protocol-buffers/docs/encoding#signed-ints) | [Fixed-size encoding](https://developers.google.com/protocol-buffers/docs/encoding#non-varint_numbers) |
| :--------- | :-------------------------------------------------------------------------------------- | :------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------- |
| `Int32`    | `Int32`                                                                                 | `SignedInteger<Int32>`                                                                      | `FixedSize<Int32>`                                                                                     |
| `Int64`    | `Int64`                                                                                 | `SignedInteger<Int64>`                                                                      | `FixedSize<Int64>`                                                                                     |
| `UInt32`   | `UInt32`                                                                                | -                                                                                           | `FixedSize<UInt32>`                                                                                    |
| `UInt64`   | `UInt64`                                                                                | -                                                                                           | `FixedSize<UInt64>`                                                                                    |

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
 
#### Signed integers

Integers are by default [encoded as `Varint` values](BinaryFormat.md#integer-encoding), which is efficient while numbers are small and positive. For numbers which are mostly or also often negative, it is more efficient to store them using `Zig-Zag` encoding. `BinaryCodable` offers the `SignedValue` wrapper that can be applied to `Int`, `Int32` and `Int64` properties to increase the efficiency for negative values.

Whenever your integers are expected to be negative, then you should apply the wrapper:
```swift
struct MyStruct: Codable {

    /// More efficiently encodes negative numbers
    @SignedValue 
    var count: Int
}
```

### Enums

Protocol Buffer [enumerations](https://developers.google.com/protocol-buffers/docs/proto3#enum) are supported, with a few notable caveats. Here is the example from the official documentation:
```proto
message SearchRequest {

    ...

    enum Corpus {
        UNIVERSAL = 0;
        WEB = 1;
        IMAGES = 2;
        LOCAL = 3;
        NEWS = 4;
        PRODUCTS = 5;
        VIDEO = 6;
    }
    Corpus corpus = 4;
}
```
The `BinaryCodable` Swift equivalent would be:

```swift
struct SearchRequest: Codable {

    ...
    
    enum Corpus: Int, Codable {
        case universal = 0
        case web = 1
        case images = 2
        case local = 3
        case news = 4
        case products = 5
        case video = 6
    }
    
    var corpus: Corpus
    
    enum CodingKeys: Int, CodingKey {
        case corpus = 4
    }
}
```

It should be noted that protobuf enums require a default key `0`.

### Oneof

The protobuf feature [Oneof](https://developers.google.com/protocol-buffers/docs/proto3#oneof) can also be supported using a special enum definition. Given the protobuf definition (from [here](https://github.com/apple/swift-protobuf/blob/main/Documentation/API.md#oneof-fields)):

```proto
syntax = "proto3";
message ExampleOneOf {
   int32 field1 = 1;
   oneof alternatives {
       int64 id = 2;
       string name = 3;
   }
}
```

The corresponding Swift definition would be:

```swift
struct ExampleOneOf: Codable {

    let field1: Int32

    // The oneof field
    let alternatives: Alternatives
 
    // The OneOf definition
    enum Alternatives: Codable, ProtobufOneOf {
        case id(Int64)
        case name(String)
         
        // Field values, must not overlap with `ExampleOneOf.CodingKeys`
        enum CodingKeys: Int, CodingKey {
            case id = 2
            case name = 3
        }
    }
     
    enum CodingKeys: Int, CodingKey {
        case field1 = 1
        // The field id of the Oneof field is not used
        case alternatives = 123456
    }
 }
 ```

Note that the `Alternatives` enum must conform to `ProtobufOneOf`, which changes the encoding to create compatibility with the Protobuf binary format.

**Important** The `ProtobufOneOf` protocol must not be applied to any other types, or encoding/decoding will fail.
