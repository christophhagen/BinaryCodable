import Foundation

/// The largest value (inclusive) for a valid integer coding key
private let intKeyUpperBound = Int(bitPattern: 0x07FFFFFFFFFFFFFF)

/// The smallest value (inclusive) for a valid integer coding key
private let intKeyLowerBound = Int(bitPattern: 0x87FFFFFFFFFFFFFF)

/**
 A wrapper around a coding key to allow usage in dictionaries.
 */
struct CodingKeyWrapper {
    
    let codingKey: CodingKey

    /**
     Create a wrapper around a coding key.
     */
    init(_ codingKey: CodingKey) {
        if let int = codingKey.intValue {
            // Check that integer key is in valid range
            if int > intKeyUpperBound || int < intKeyLowerBound {
                fatalError("Integer key \(int) is out of range for coding key \(codingKey.stringValue)")
            }
        }
        self.codingKey = codingKey
    }

    /**
     Encode a coding key for a value of a specific type.
     - Parameter dataType: The data type of the value associated with this key.
     - Returns: The encoded data of the coding key, the data type and the key type indicator.
     */
    func encode(for dataType: DataType) -> Data {
        guard let intValue = codingKey.intValue else {
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
        let count = codingKey.stringValue.count
        let data = encode(int: count, for: dataType, isStringKey: true)
        // It's assumed that all property names can be represented in UTF-8
        return data + codingKey.stringValue.data(using: .utf8)!
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
        // LSB is the string key indicator
        // Bit 1-3 are the data type
        // Remaining bits are the integer
        let mixed = (int << 4) | (dataType.rawValue << 1) | (isStringKey ? 1 : 0)
        return mixed.variableLengthEncoding
    }
}

extension CodingKeyWrapper: Equatable {
    
    static func == (lhs: CodingKeyWrapper, rhs: CodingKeyWrapper) -> Bool {
        lhs.codingKey.stringValue == rhs.codingKey.stringValue
    }
}

extension CodingKeyWrapper: Hashable {
    
    func hash(into hasher: inout Hasher) {
        if let int = codingKey.intValue {
            hasher.combine(int)
        } else {
            hasher.combine(codingKey.stringValue)
        }
    }
}

extension CodingKeyWrapper: Comparable {

    static func < (lhs: CodingKeyWrapper, rhs: CodingKeyWrapper) -> Bool {
        if let lhsInt = lhs.codingKey.intValue, let rhsInt = rhs.codingKey.intValue {
            return lhsInt < rhsInt
        }
        return lhs.codingKey.stringValue < rhs.codingKey.stringValue
    }
}

extension CodingKeyWrapper: CustomStringConvertible {
    
    var description: String {
        if let int = codingKey.intValue {
            return codingKey.stringValue + " (\(int))"
        }
        return codingKey.stringValue
    }
}
