import Foundation

/**
 The data type specifying how a value is encoded on the wire.
 
 The data type is mixed into the key for each value to indicate how many bytes the value occupies in the following bytes.
 */
enum DataType: Int {
    
    /**
     An integer value encoded as a var-int. The length can be determined by reading the value.
     
     Used for: `Int`, `Int32`, `Int64`,  `UInt`, `UInt32`, `UInt64`
     */
    case variableLengthInteger = 0
    
    /**
     The value is encoded as a single byte.
     
     Used for: `Bool`, `UInt8`, `Int8`
     */
    case byte = 1
    
    /**
     The value is encoded as two bytes.
     
     Used for: `Int16`, `UInt16`
     */
    case twoBytes = 2

    /**
     The value is encoded using first a length (as a UInt64 var-int) followed by the bytes.

     Used by: `String`, complex types
     */
    case variableLength = 3
    
    /**
     The value is encoded using four bytes.
     
     Used for: `Float`, `FixedWidth<Int32>`, `FixedWidth<UInt32>`
     */
    case fourBytes = 4
    
    /**
     The value is encoded using eight bytes.

     Used by: `Double`, `FixedWidth<Int64>`, `FixedWidth<Int>`, `FixedWidth<UInt64>`, `FixedWidth<UInt>`
     */
    case eightBytes = 5

    var byteCount: Int? {
        switch self {
        case .variableLengthInteger, .variableLength:
            return nil
        case .byte:
            return 1
        case .twoBytes:
            return 2
        case .fourBytes:
            return 4
        case .eightBytes:
            return 8
        }
    }
}
