import Foundation

/**
 The largest value (inclusive) for a valid integer coding key.
 
 The value is an integer with all but the first 5 MSB set to `1`.

 On 64 bit systems, the value is:

 Hex: `0x07FFFFFFFFFFFFFF`

 Decimal: `576460752303423487`

 Mathmatically: `2^59-1`
 
 On 32 bit systems, the value is:
 
 Hex: `0x07FFFFFF`

 Decimal: `134217727`

 Mathmatically: `2^27-1`
 */
private let intKeyUpperBound = Int(bitPattern: ~UInt(0) >> 5)

/**
 The smallest value (inclusive) for a valid integer coding key.
 
 The value is an integer with only the first 5 MSB set to `1`.

 On 64 bit systems, the value is:

 Hex: `0xF800000000000000`

 Decimal: `-576460752303423488`

 Mathmatically: `-2^59`
 
 On 32 bit systems, the value is:
 
 Hex: `0xF8000000`

 Decimal: `-134217728`

 Mathmatically: `-2^27`
 */
private let intKeyLowerBound = Int(bitPattern: 0xF8 << (UInt.bitWidth - 8))


protocol CodingKeyWrapper {

    func encode(for dataType: DataType) -> Data
}

/**
 A wrapper around a coding key to allow usage in dictionaries.
 */
struct MixedCodingKeyWrapper: CodingKeyWrapper {
    
    private let intValue: Int?

    private let stringValue: String

    /**
     Create a wrapper around a coding key.
     */
    init(_ codingKey: CodingKey) {
        if let int = codingKey.intValue {
            // Check that integer key is in valid range
            if int > intKeyUpperBound || int < intKeyLowerBound {
                fatalError("Integer key \(int) is out of range [\(intKeyLowerBound)...\(intKeyUpperBound)] for coding key \(codingKey.stringValue)")
            }
        }
        self.intValue = codingKey.intValue
        self.stringValue = codingKey.stringValue
    }

    init(intValue: Int?, stringValue: String) {
        self.intValue = intValue
        self.stringValue = stringValue
    }

    /**
     Encode a coding key for a value of a specific type.
     - Parameter dataType: The data type of the value associated with this key.
     - Returns: The encoded data of the coding key, the data type and the key type indicator.
     */
    func encode(for dataType: DataType) -> Data {
        guard let intValue = intValue else {
            return encodeStringValue(for: dataType)
        }
        return encode(int: intValue, for: dataType, isStringKey: false)
    }

    /**
     Encode the string value of the coding key.
     - Parameter dataType: The data type of the value associated with this key.
     - Returns: The encoded data of the coding key, the data type and the key type indicator.
     */
    private func encodeStringValue(for dataType: DataType) -> Data {
        let count = stringValue.count
        let data = encode(int: count, for: dataType, isStringKey: true)
        // It's assumed that all property names can be represented in UTF-8
        return data + stringValue.data(using: .utf8)!
    }

    /**
     Encode an integer value with a data type and the string key indicator.

     - Note: The integer is encoded using variable-length encoding.
     - Note: Integer range is checked in constructor. It's also assumed that a property name will not exceed 2^59 characters.
     - Parameter int: The integer (either string key length or integer key) to encode.
     - Parameter dataType: The data type of the value associated with this key.
     - Returns: The encoded data of the integer, the data type and the key type indicator.
     */
    private func encode(int: Int, for dataType: DataType, isStringKey: Bool) -> Data {
        // Bit 0-2 are the data type
        // Bit 3 is the string key indicator
        // Remaining bits are the integer
        let mixed = (int << 4) | dataType.rawValue | (isStringKey ? 0x08 : 0x00)
        return mixed.variableLengthEncoding
    }
}

extension MixedCodingKeyWrapper: Equatable {
    
    static func == (lhs: MixedCodingKeyWrapper, rhs: MixedCodingKeyWrapper) -> Bool {
        lhs.stringValue == rhs.stringValue
    }
}

extension MixedCodingKeyWrapper: Hashable {
    
    func hash(into hasher: inout Hasher) {
        if let int = intValue {
            hasher.combine(int)
        } else {
            hasher.combine(stringValue)
        }
    }
}

extension MixedCodingKeyWrapper: Comparable {

    static func < (lhs: MixedCodingKeyWrapper, rhs: MixedCodingKeyWrapper) -> Bool {
        if let lhsInt = lhs.intValue, let rhsInt = rhs.intValue {
            return lhsInt < rhsInt
        }
        return lhs.stringValue < rhs.stringValue
    }
}

extension MixedCodingKeyWrapper: EncodingContainer {

    var data: Data {
        if let intValue = intValue {
            return UInt64(intValue).protobufData()
        }
        return stringValue.data(using: .utf8)!
    }

    var dataType: DataType {
        intValue != nil ? Int.dataType: String.dataType
    }

    var isEmpty: Bool { false }
}
