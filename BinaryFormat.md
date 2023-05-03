# Binary data structure

**Note:** The `BinaryCodable` format is optimized for size, but does not go all-out to create the smallest binary sizes possible. 
The binary format, while being efficient, needs to serve as a general-purpose encoding, which will never be as efficient than a custom format optimized for a very specific use case.
If this is your goal, then simply using `Codable` with it's key-value approach will not be the best solution. An unkeyed format optimized for the actually encoded data will be more suitable. But if you're really looking into this kind of efficiency, then you probably know this already.

The encoding format used by `BinaryCodable` is similar to Google's [Protocol Buffers](https://developers.google.com/protocol-buffers) in some aspects, but provides much more flexibility regarding the different types which can be encoded, including the ability to encode `Optional`, `Set`, single values, multidimensional `Array`s, and more.

## Integer encoding

Integers are encoded with different strategies depending on their size. Smaller types, like `UInt8`, `Int8`, `UInt16`, and `Int16` are encoded using their binary representations in little-endian format.

Larger integers, like `UInt32`, `Int32`, `UInt64`, `Int64`, `Int`, and `UInt` are (by default) encoded using variable length zig-zag encoding, similar to [Protobuf signed integers](https://developers.google.com/protocol-buffers/docs/encoding#signed-ints). This means that smaller values are encoded as shorter binary representations, which is useful if integer values are mostly small.
**Note:** The `Varint` implementation is not equivalent to `Protobuf`, since `BinaryCodable` uses the last byte of a large integer directly, and thus encodes `Int.max` with 9 Byte instead of 10. This encoding is adapted when enforcing protobuf compatibility.

The property wrapper [`FixedSize`](#fixed-size-integers) forces the values to be encoded using their little-endian representations.

## Floating-point types

`Float` and `Double` values are encoded using their binary representations in little-endian format.

## Strings

Swift `String` values are encoded using their `UTF-8` representations. If a string can't be encoded this way, then encoding fails.

## Booleans

`Bool` values are always encoded as a single byte, using `1` for `true`, and `0` for `false`.

## Arrays

Arrays (and other sequences) are encoded by converting each item to binary data, and concatenating the results. Elements with variable length (like `String`) are prepended with their length encoded as a [Varint](#integer-encoding).

### Arrays of Optionals

It is possible to encode arrays where the elements are `Optional`, e.g. `[Bool?]`. 
For all types with compiler-generated `Codable` conformance, an optional is prepended with one byte (`1` for the `.some()` case, `0` for `nil`).
If the optional has a value, then the encoded data follows the `1` byte.
If `nil` is encoded, then no additional data is added.
This means that an array of `[Bool?]` with the values `[true, nil, false]` is encoded as `[1, 1, 0, 1, 0]`.

- Note: One benefit of this encoding is that top-level sequences can be joined using their binary data, where `encoded([a,b]) | encoded([c,d]) == encoded([a,b,c,d])`.

Custom implementations of `Encodable` and `Decodable` can directly call `encodeNil()` on `UnkeyedEncodingContainer` and `decodeNil()` on `UnkeyedDecodingContainer`.
This feature is not supported in the standard configuration and will result in a fatal error.
If these functions are needed, then the `prependNilIndexSetForUnkeyedContainers` must be set for the encoder and decoder.
If this option is set to `true`, then each unkeyed container is prepended with a "nil index set". 
It first consists of the number of `nil` elements in the sequence (only those encoded using `encodeNil()`), encoded as a `Varint`. 
Then follow the indices in the array where `nil` values are present, each encoded as a `Varint`. 
The decoder can then first parse this `nil` set, and return the appropriate value for each position where a `nil` value is encoded when `decodeNil()` is called. 
This approach is fairly efficient while only few `nil` values are encoded, or while the sequence doesn't contain a large number of elements.
For arrays that don't contain optionals, only a single byte (`0`) is prepended to the binary representation, to signal that there are no `nil` indices in the sequence.

More efficient ways could be devised to handle arrays of optionals, like specifying the number of `nil` or non-nil elements following one another, but the increased encoding and decoding complexity don't justify these gains in communication efficiency.

## Structs

Structs are encoded using `Codable`'s `KeyedEncodingContainer`, which uses `String` or `Int` coding keys to distinguish the properties of the types.
By default, Swift uses the property names as `String` keys, which are used to encode each property as a key-value pair on the wire.
The first value is a `Varint`, which contains the length of the string key, plus additional information about the data associated with the key.
The bits 0-2 are used to signal the size value, and bit 3 of the `Varint` indicates whether the key is a string key (`1` = string, `0` = int).
The following data types are possible:

| Data type               | Raw value | Protobuf          | Swift types                                                                            | Description                                                             |
| :---------------------- | :-------- | :---------------- | :------------------------------------------------------------------------------------- |
| `variableLengthInteger` | `0`       | `varint`/`zigzag` | `Int`, `Int32`, `Int64`,  `UInt`, `UInt32`, `UInt64`                                   | A Base128 `Varint` using 1-9 bytes of data                              |
| `eightBytes`            | `1`       | `fixed64bit`      | `Double`, `FixedSize<Int64>`, `FixedSize<Int>`, `FixedSize<UInt64>`, `FixedSize<UInt>` | A 64-bit float or integer in little-endian encoding.                    |
| `variableLength`        | `2`       | `delimited`       | `String`, `Struct`, ...                                                                | The length of the data encoded as a `Varint` followed by `length` bytes |
| `fourBytes`             | `5`       | `fixed32bit`      | `Float`, `FixedSize<Int32>`, `FixedSize<UInt32>`                                       | A 32-bit float or integer in little-endian encoding.                    |
| `byte`                  | `6`       | -                 | `Bool`, `UInt8`, `Int8`                                                                | A single byte storing a number or boolean                               |
| `twoBytes`              | `7`       | -                 | `Int16`, `UInt16`                                                                      | Two bytes storing an integer using little-endian format                 |


With the four lower bits occupied by the data type and the string key indicator, the remaining bits are left to encode the length of the string key.

For example, a property named `xyz`  of type `UInt8` with value `123` would be encoded to the following:

| Byte 0                                     | Byte 1     | Byte 2     | Byte 3     | Byte 4     |
| :----------------------------------------- | :--------- | :--------- | :--------- | :--------- |
| `0` `011` `1` `110`                        | `01111000` | `01111001` | `01111010` | `01111011` |
| Length `3`, `String` key, Data type `byte` | `x`        | `y`        | `z`        | `123`      |

### Integer keys

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

| Byte 0                                       | Byte 1     |
| :------------------------------------------- | :--------- |
| `0` `010` `0` `110`                          | `01111011` |
| Integer key `2`, `Int` key, Data type `byte` | `123`      |

Evidently this is a significant improvement, especially for long property names. Note that while it is possible to specify any integer as the key (between 2^59 and -2^59), small, positive integers are the most efficient.

### Optional properties

Any properties of structs or other keyed containers is omitted from the binary data, i.e. nothing is encoded. 
The absence of a key then indicates to the decoder that the value is `nil`.
For multiple optionals (e.g. `Bool??`), the inner optional is encoded as a `varLen` type, with the same encoding as optionals in arrays. 

## Codable quirks

There are some interesting details on how `Codable` treats certain types, which produce unexpected binary data. Although `BinaryCodable` decodes all these cases correctly, implementing these "features" may be difficult on other platforms.

### Enums with associated values

Given an enum with associated values: 

```swift
enum MyEnum: Codable {
    case one(String)
    case two(Bool, Data)
}
```

The encoding will consist of:
- The enum case name as a String key
- A keyed container with:
  - All associated values in the order of their definition, keyed by `"_0"`, `"_1"`, ...

For example, the value

```swift
let value = MyEnum.one("Some")
```

would be encoded as:

| Byte 0                          | Byte 1 - 3       | Byte 4     | Byte 5             | Byte 6 - 7  | Byte 8     | Byte 9 - 12           |
| :------------------------------ | :--------------- | :--------- | :----------------- | :---------- | :--------- | :-------------------- |
| `0x3A`                          | `0x6F 0x6E 0x65` | `0x08`     | `0x2A`             | `0x5F 0x30` | `0x04`     | `0x53 0x6E 0x64 0x08` |
| `String` key (Len 3),  `VarLen` | `one`            | Length `8` | String key (Len 2) | `_0`        | Length `4` | `Some`                |

Let's use the same example with integer keys:

```swift
enum MyEnum: Codable {
    case one(String)
    case two(Bool, UInt8)

    enum CodingKeys: Int, CodingKey {
        case one = 1
        case two = 2
    }
}
```

Then, the value

```swift
let value = MyEnum.two(true, 123)
```

would be encoded as:

| Byte 0                   | Byte 1     | Byte 2                     | Byte 3 - 4  | Byte 5       | Byte 6                     | Byte 7 - 8  | Byte 9       |
| :----------------------- | :--------- | :------------------------- | :---------- | :----------- | :------------------------- | :---------- | :----------- |
| `0x22`                   | `0x08`     | `0x2E`                     | `0x5F 0x30` | `0x01`       | `0x2E`                     | `0x5F 0x31` | `0x7B`       |
| `Int` key (2),  `VarLen` | Length `8` | String key (Len 2), `Byte` | `_0`        | `Bool(true)` | String key (Len 2), `Byte` | `_1`        | `UInt8(123)` |

Note: Since the associated values are encoded in a keyed container, there order in the binary data may be different, unless the `sortKeysDuringEncoding` option is set to `true`.

### Special dictionaries

Most dictionaries are treated as `Unkeyed Containers` by `Codable`, and each key value pair is encoded by first encoding the key, followed by the value, thus creating the  flat structure:

| Key 1 | Value 1 | Key 2 | Value 2 | Key 3 | Value 3 |
| :---- | :------ | :---- | :------ | :---- | :------ |

#### Dictionaries with Integer keys

For all dictionaries, which use `Int` as the key, e.g. `[Int: String]`, `[Int: Int]`, or generally `[Int: ...]`, the encoding is done using a `Keyed` container, where each dictionary value is encoded using a `CodingKey` with an integer value. This results in a structure more resembling [struct encoding](#structs) with [integer keys](#integer-keys):

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

The encoding for data streams is only differs from standard encoding in two key aspects.

### Added length information

Each top-level element is encoded as if it is part of an unkeyed container (which it essentially is), meaning that each element has the necessary length information prepended to determine it's size.
Only types with data type `variable length` have their length prepended using [varint](#integer-encoding) encoding.
This concerns `String` and `Data`, as well as complex types like structs and arrays, among others.

### Optionals

A single byte is prepended to each `Optional` element, where binary `0x01` is used to indicate a non-optional value, and `0x00` is used to signal an optional value. 
`nil` values have no additional data, so each is encoded using one byte.
