import Foundation

/// The largest value (inclusive) for a valid protobuf field number (536870911)
private let protoFieldUpperBound = 0x1FFFFFFF

/// The smallest value (inclusive) for a valid integer coding key
private let protoFieldLowerBound = 1

/**
 Wraps a protobuf field number to use as a coding key.
 */
struct IntKeyWrapper: CodingKeyWrapper {

    private let intValue: Int

    static func checkFieldBounds(_ field: Int) throws {
        if field < protoFieldLowerBound || field > protoFieldUpperBound {
            throw ProtobufEncodingError.integerKeyOutOfRange(field)
        }
    }

    init(value: Int) throws {
        try IntKeyWrapper.checkFieldBounds(value)
        self.intValue = value
    }

    init(_ key: CodingKey) throws {
        guard let value = key.intValue else {
            throw ProtobufEncodingError.missingIntegerKey(key.stringValue)
        }
        try self.init(value: value)
    }

    func encode(for dataType: DataType) -> Data {
        // Bit 0-2 are the data type
        // Remaining bits are the integer
        let mixed = (intValue << 3) | dataType.rawValue
        return mixed.variableLengthEncoding
    }
}

extension IntKeyWrapper: EncodingContainer {

    var data: Data {
        UInt64(intValue).protobufData()
    }

    var dataType: DataType {
        Int.dataType
    }

    var isEmpty: Bool {
        false
    }
}


extension IntKeyWrapper: Hashable {

}

extension IntKeyWrapper: Equatable {

}

extension IntKeyWrapper: Comparable {

    static func < (lhs: IntKeyWrapper, rhs: IntKeyWrapper) -> Bool {
        lhs.intValue < rhs.intValue
    }
}
