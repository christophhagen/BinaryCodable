import Foundation

/**
 The data type specifying how a value is encoded on the wire.
 
 The data type is mixed into the key for each value to indicate how many bytes the value occupies in the following bytes.

 The data type is equivalent to the [Protocol Buffer Wire Type](https://developers.google.com/protocol-buffers/docs/encoding#structure), but extended to support more data types.
 */
public enum DataType: Int {
    
    /**
     An integer value encoded as a Base128 Varint.
     The length can be determined by reading the value,
     where the first (MSB) indicates whether another byte follows.
     A Varint consumes up to 9 bytes, where all bits from the last byte are used,
     resulting in `8 * 7 + 8 = 64` usable bits.

     For Protobuf encoding, the Varint can use up to 10 bytes, since the MSB is used for all bytes, including byte 9.

     See also [Protocol Buffers: Base 128 Varints](https://developers.google.com/protocol-buffers/docs/encoding#varints).
     
     Used for: `Int`, `Int32`, `Int64`,  `UInt`, `UInt32`, `UInt64`, `Bool`
     */
    case variableLengthInteger = 0
    
    /**
     The value is encoded as a single byte.

     - Note: This data type is incompatible with the protocol buffer specification.
     
     Used for: `UInt8`, `Int8`
     */
    case byte = 6
    
    /**
     The value is encoded as two bytes.

     - Note: This data type is incompatible with the protocol buffer specification.
     
     Used for: `Int16`, `UInt16`
     */
    case twoBytes = 7

    /**
     The value is encoded using first a length (as a UInt64 var-int) followed by the bytes.

     Used by: `String`, `Data`, complex types
     */
    case variableLength = 2
    
    /**
     The value is encoded using four bytes.
     
     Used for: `Float`, `FixedWidth<Int32>`, `FixedWidth<UInt32>`
     */
    case fourBytes = 5
    
    /**
     The value is encoded using eight bytes.

     Used by: `Double`, `FixedWidth<Int64>`, `FixedWidth<Int>`, `FixedWidth<UInt64>`, `FixedWidth<UInt>`
     */
    case eightBytes = 1

    /**
     Decode a data type from an integer tag.

     The integer tag includes both the integer field key (or string key length) and the data type,
     where the data type is encoded in the three LSB.
     - Parameter value: The raw tag value.
     - Throws: `DecodingError.dataCorrupted()`, if the data type is unknown (3 or 4)
     */
    init(decodeFrom value: Int, path: [CodingKey]) throws {
        let rawDataType = value & 0x7
        guard let dataType = DataType(rawValue: rawDataType) else {
            let context = DecodingError.Context(codingPath: path, debugDescription: "Unknown data type \(rawDataType)")
            throw DecodingError.dataCorrupted(context)
        }
        self = dataType
    }

    /**
     Indicate that the datatype is also available in the protobuf specification.

     All data types except `.byte` and `.twoBytes` are compatible.
     */
    var isProtobufCompatible: Bool {
        switch self {
        case .variableLengthInteger, .variableLength, .fourBytes, .eightBytes:
            return true
        case .byte, .twoBytes:
            return false
        }
    }
}
