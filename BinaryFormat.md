# Binary data structure

**This document describes the binary format of version 3. For version 2 and below, see [legacy format](LegacyFormat.md)**

**Note:** The `BinaryCodable` format is optimized for size, but does not go all-out to create the smallest binary sizes possible.
The binary format, while being efficient, needs to serve as a general-purpose encoding, which will never be as efficient than a custom format optimized for a very specific use case.
If this is your goal, then simply using `Codable` with it's key-value approach will not be the best solution. 
An unkeyed format optimized for the actually encoded data will be more suitable.
But if you're really looking into this kind of efficiency, then you probably know this already.

The encoding format used by `BinaryCodable` has been designed to be efficient, while at the same time supporting all features of the `Codable` implementation.

## Basic types

The basic types known to `Codable` are listed in the following table:

| Type | Length | Encoding |
| --- | --- | --- |
| Bool | 1 | false: `0x00`, true: `0x01` |
| Data | ? | As itself
| Double | 8 | IEEE Double representation, little endian |
| Float | 4 |IEEE Double representation, little endian |
| Int8 | 1 | [Little endian](#little-endian) |
| Int16 | 2 | [Little endian](#little-endian) |
| Int32 | 1-5 | Zig-zag variable-length encoding |
| Int64 | 1-9 | Zig-zag variable-length encoding |
| Int | 1-9 | Zig-zag variable-length encoding |
| String | ? | UTF-8 data |
| UInt8 | 1 | [Little endian](#little-endian) |
| UInt16 | 2 | [Little endian](#little-endian) |
| UInt32 | 1-5 | [Variable-length encoding](#variable-length-encoding) |
| UInt64 | 1-10 | [Variable-length encoding](#variable-length-encoding) |
| UInt | 1-10 | [Variable-length encoding](#variable-length-encoding) |

`BinaryCodable` also adds the following alternative encodings using the [`FixedSize`](#fixed-size-integers) property wrapper:

| Type | Length | Encoding |
| --- | --- | --- |
| FixedSize\<Int32\> | 4 | [Little endian](#little-endian) |
| FixedSize\<Int64\> | 8 | [Little endian](#little-endian) |
| FixedSize\<Int\> | 8 | [Little endian](#little-endian) |
| FixedSize\<UInt32\> | 4 | [Little endian](#little-endian) |
| FixedSize\<UInt64\> | 8 | [Little endian](#little-endian) |
| FixedSize\<UInt\> | 8 | [Little endian](#little-endian) |

`FixedSize` can be used as a property wrapper, to transparently change the encoding:

```swift
struct MyType: Codable {

    @FixedSize
    var userId: Int64
}
```

### Boolean

`Bool` values are encoded as a single byte, using `1` for `true`, and `0` for `false`.

### Little endian

Smaller integer types, like `UInt8`, `Int8`, `UInt16`, and `Int16` are encoded using their binary representations in little-endian format.
This format is chosen since most Apple architectures already store data as little-endian.

### Variable-length encoding

Larger unsigned integers (`UInt32`, `UInt64` and `UInt`) are (by default) encoded using variable length encoding, similar to [Protobuf Base128 Varints](https://protobuf.dev/programming-guides/encoding/#varints).
This means that smaller values are encoded as shorter binary representations, which is useful if integer values are mostly small.

**Note:** The `Varint` implementation is not equivalent to `Protobuf`, since `BinaryCodable` uses the last byte of a large integer directly (no continuation bit), and thus encodes `Int.max` with 9 Byte instead of 10.

### Zig-zag encoding

Larger signed integers (`Int32`, `Int64` and `Int`) are (by default) encoded using zig-zag encoding, similar to [Protobuf signed integers](https://developers.google.com/protocol-buffers/docs/encoding#signed-ints). 
This format is more efficient for integers where the magnitude is small.

### Fixed-size integers

The property wrapper `FixedSize` forces the wrapped values to be encoded using their little-endian representations.
This is useful if the integer values are often large, e.g. for random numbers.

### Floating-point types

`Float` and `Double` values are encoded using their binary representations in little-endian format.

### Strings

Swift `String` values are encoded using their `UTF-8` representations. 
If a string can't be encoded this way, then encoding fails.

## Containers

Every `Codable` structure is in some way constructed from just a the described basic types, which are arranged in three different containers:
 
**Single value containers** can contain only a single element, or alternatively `nil`.

**Unkeyed containers** can store a sequence of different values (including `nil` values).

**Keyed containers** consist of values, which are associated with `CodingKey`s (either a String or an Int value).

Each of these containers can either encode [basic types](#basic-types), or include nested containers.
No matter what is encoded, each element is usually preceded by a length indicator, to show the decoder where the container ends.

### Single Value Container encoding

Since a single value container can contain `nil`, it's encoding always requires a `nil` indicator.
At the top level, this is a single byte of either `1` to indicate `nil` (with no additional data folling it), or `0`, to indicate that the encoded value follows.
If a single value container is nested in some other container, then the `nil` indicator is contained in the length information that is prepended to the container data.

### Unkeyed containers

Unkeyed containers can contain values of different types in a sequence.
Each value (other containers or basic types) is encoded using its encoded data, prefixed by a length indicator to signal the decoder how many bytes are associated with each value.
This enables the decoder to split the data into separate chunks before the actual types are decoded.

### Length/nil indicators

The length indicators for each encoded value in an unkeyed container consists of an unsigned integer, encoded using [variable-length encoding](#variable-length-encoding).
The length is not directly encoded as an integer, but shifted to the left by one bit, so that the LSB can be used as a `nil` indicator.
If the LSB is set, then `nil` is encoded for the value, and all other bits must be unset.
If the LSB is set to `0`, then the value is not `nil`, and the integer indicates the number of bytes used by the value's encoded data.

For example assume the following encoding routine:

```swift
var container = encoder.unkeyedContainer()
try container.encode(false)
try container.encodeNil()
try container.encode("Hello")
try container.encode(Data())
```

This yields the following binary representation (hex):

```
02 00 01 14 48 65 6C 6C 6F 00
```

which translates to:

```
0x02 // First element is not nil, length 1
0x00 // First element data (Bool `false`)
0x01 // Second element is nil
0x14 // Third element is not nil, length 5
0x48656C6C6F // Third element data, String "Hello"
0x00 // Fourth element is not nil, length 0
```

### Keyed containers

Keyed containers work similar to unkeyed containers, except that each element also has a key inserted before the element data.

Keys can be of type `String` or `Int`.
For both types, and unsigned integer is encoded using [variable-length encoding](#variable-length-encoding).
If the key is an integer, then the LSB is set to `0`, and the remaining value (shifted by 1 to remove the LSB) indicates the value of the integer key.
So an integer key of `1` is encoded as `0x02`, a key of `2` as `0x04` and so on.
This process is very similar to the encoding of the length or `nil` described in the previous chapter.

If the key is a string, then the LSB is set to `1`, and the remaining integer specifies the length of the string key.
The actual string is then appended in its [encoded form](#strings).
So a string key of "value" is encoded as:

```
11 // String key, length 5
118, 97, 108, 117, 101 // String "value"
```

After the key data follows the actual element data, consisting (similar to unkeyed containers) of the length/nil indicator and the encoded value.

### Basic example

Consider the following swift structure:

```swift
struct Message: Codable {
    let isComplete: Bool
    let owner: String?
    let references: [Int]

    enum CodingKeys: Int, CodingKey {
        case isComplete = 1
        case owner = 2
        case references = 3
    }
}
```

Encode the message

```swift
let message = Message(
    isComplete: true
    owner: "Bob"
    references: [3, -280])
```

will give the following binary data:

| Byte index | Value | Content |
|--- |--- |--- |
| 0 | 0x02 | CodingKey(stringValue: 'isComplete', intValue: 1)
| 1 | 0x02 | Length 1
| 2 | 0x01 | Bool `true`
| 3 | 0x04 | CodingKey(stringValue: 'owner', intValue: 2)
| 4 | 0x06 | Length 3
| 5-7 | 0x42 0x6f 0x62 | String "Bob"
| 8 | 0x06 | CodingKey(stringValue: 'references', intValue: 3)
| 9 | 0x0A | Length 5
| 10 | 0x02 | Length 1
| 11 | 0x06 | Int `3`
| 12 | 0x04 | Length 2
| 13-14 | 0xAF 0x04 | Int `-280`

There are a few things to note:
- The properties are all marked by their integer keys
- The elements in the `references` array are also preceded by a length indicator
- The top level keyed container has no length information, since it can be inferred from the length of the provided data

### Dictionaries

Most dictionaries are treated as `Unkeyed Containers` by `Codable`, and each key value pair is encoded by first encoding the key, followed by the value, thus creating the  flat structure:

| Key 1 | Value 1 | Key 2 | Value 2 | Key 3 | Value 3 |
| :---- | :------ | :---- | :------ | :---- | :------ |

#### Dictionaries with Integer keys

For all dictionaries using `Int` as the key, e.g. `[Int: String]`, `[Int: Int]`, or generally `[Int: ...]`, the encoding is done using a `Keyed` container, where each dictionary value is encoded using a `CodingKey` with an integer value. This results in a structure more resembling [struct encoding](#structs) with [integer keys](#integer-keys):

| Byte(s)                     | Byte(s) | Byte(s)                     | Byte(s) | Byte(s)                     | Byte(s) |
| :-------------------------- | :------ | :-------------------------- | :------ | :-------------------------- | :------ |
| `Int` Key(Key 1), Data type | Value 1 | `Int` Key(Key 2), Data type | Value 2 | `Int` Key(Key 3), Data type | Value 3 |

For example, the following works:

```swift
struct MyStruct: Codable {
    let a: Int
    let b: Int
    let c: Int
}

// Encode a dictionary
let input: [String: Int] = ["a" : 123, "b": 0, "c": -123456]
let data = try BinaryEncoder.encode(input)

// Decode as struct
let decoded = try BinaryDecoder.decode(MyStruct.self, from: data)
```

It also works the other way round:
```swift
// Encode struct
let input = MyStruct(a: 123, b: 0, c: -123456)
let data = try BinaryEncoder.encode(input)

// Decode as dictionary
let decoded: [String: Int] = try BinaryDecoder.decode(from: data)
```

Note that this only works for dictionaries with concrete `Encodable` values, e.g. `[String: Encodable]` won't work.

#### Dictionaries with String keys

For dictionaries with `String` keys (`[String: ...]`), the process is similar to the above, except with `CodingKey`s having the `stringValue` of the key. There is another weird exception though: Whenever a `String` can be represented by an integer (i.e. when `String(key) != nil`), then the corresponding `CodingKey` will have its `integerValue` also set. This means that for dictionaries with integer keys, there may be a mixture of integer and string keys present in the binary data, depending on the input values. But don't worry, `BinaryCodable` will also handle these cases correctly.

## Stream encoding

The encoding for data streams only differs from standard encoding in one key aspect.
Each top-level element is encoded as if it is part of an unkeyed container (which it essentially is), meaning that each element has the necessary length information prepended to determine its size.