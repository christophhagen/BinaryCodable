import Foundation

struct IntKeyWrapper: CodingKeyWrapper {

    private let intValue: Int

    init(value: Int) {
        self.intValue = value
    }

    init(_ key: CodingKey) throws {
        guard let value = key.intValue else {
            throw BinaryEncodingError.notProtobufCompatible("Int key required")
        }
        self.intValue = value
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
