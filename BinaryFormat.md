# Binary data structure

**Note:** The `BinaryCodable` format is optimized for size, but does not go all-out to create the smallest binary sizes possible. If this is your goal, then simply using `Codable` with it's key-value approach will not be the best solution. An unkeyed format optimized for the actually encoded data will be more suitable. But if you're really looking into this kind of efficiency, then you probably know this already.

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

Arrays (and other sequences) are encoded by converting each item to binary data, and concatenating the results. Elements with variable length (like `String`) are prepended with their length encoded as a [Varint](#integer-encoding). Each encoded array has at least one byte prepended to it, in order to support optional values.

### Arrays of Optionals

It is possible to encode arrays where the elements are `Optional`, e.g. `[Bool?]`. Due to constraints regarding Apple's implementation of `Encoder` and `Decoder`, it is not consistently possible to infer if optionals are present in unkeyed containers. `BinaryCodable` therefore encodes optionals using a different strategy: Each array binary representation is prepended with a "nil index set". It first consists of the number of `nil` elements in the sequence, encoded as a `Varint`. Then follow the indices in the array where `nil` values are present, each encoded as a `Varint`. The decoder can then first parse this `nil` set, and return the appropriate value for each position where a `nil` value is encoded. This approach is fairly efficient while only few `nil` values are encoded, or while the sequence doesn't contain a large number of elements. For arrays that don't contain optionals, only a single byte (`0`) is prepended to the binary representation, to signal that there are no `nil` indices in the sequence.

## Structs

Structs are encoded using `Codable`'s `KeyedEncodingContainer`, which uses `String` or `Int` coding keys to distinguish the properties of the types.
By default, Swift uses the property names as `String` keys, which are used to encode each property as a key-value pair on the wire.
The first value is a `Varint`, which contains the length of the string key, plus additional information about the data associated with the key.
The bits 0-2 are used to signal the size value, and bit 3 of the `Varint` indicates whether the key is a string key (`1` = string, `0` = int).
The following data types are possible:

| Data type | Raw value | Protobuf | Swift types | Description |
|    :--    |    :--    |     :--     |     :--     |
`variableLengthInteger` | `0` | `varint`/`zigzag` | `Int`, `Int32`, `Int64`,  `UInt`, `UInt32`, `UInt64` | A Base128 `Varint` using 1-9 bytes of data
`eightBytes` | `1` | `fixed64bit` | `Double`, `FixedSize<Int64>`, `FixedSize<Int>`, `FixedSize<UInt64>`, `FixedSize<UInt>` | A 64-bit float or integer in little-endian encoding.
`variableLength` | `2` | `delimited` | `String`, `Struct`, ... | The length of the data encoded as a `Varint` followed by `length` bytes
`fourBytes` | `5` | `fixed32bit` | `Float`, `FixedSize<Int32>`, `FixedSize<UInt32>` | A 32-bit float or integer in little-endian encoding.
`byte` | `6` | - | `Bool`, `UInt8`, `Int8` | A single byte storing a number or boolean
`twoBytes` | `7` | - | `Int16`, `UInt16` | Two bytes storing an integer using little-endian format


With the four lower bits occupied by the data type and the string key indicator, the remaining bits are left to encode the length of the string key.

For example, a property named `xyz`  of type `UInt8` with value `123` would be encoded to the following:

| Byte 0 | Byte 1 | Byte 2 | Byte 3 | Byte 4 |
|  :--   |  :--   |  :--   |  :--   |  :--   |
| `0` `011` `1` `110` | `01111000` | `01111001` | `01111010` | `01111011` |
| Length `3`, `String` key, Data type `byte` | `x` | `y` | `z` | `123` |

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

| Byte 0 | Byte 1 |
|  :--   |  :--   |
| `0` `010` `0` `110` | `01111011` |
| Integer key `2`, `Int` key, Data type `byte` | `123` |

Evidently this is a significant improvement, especially for long property names. Note that while it is possible to specify any integer as the key (between 2^59 and -2^59), small, positive integers are the most efficient.

### Optional properties

Any properties of structs or other keyed containers is omitted from the binary data, i.e. nothing is encoded. The absence of a key then indicates to the decoder that the value is `nil`
