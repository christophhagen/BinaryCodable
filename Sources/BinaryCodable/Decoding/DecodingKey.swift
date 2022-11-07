import Foundation

enum DecodingKey {
    case intKey(Int)
    case stringKey(String)

    func isEqual(to key: CodingKey) -> Bool {
        switch self {
        case .intKey(let value):
            return value == key.intValue
        case .stringKey(let value):
            return value == key.stringValue
        }
    }

    private static func isStringKey(_ value: Int) -> Bool {
        value & 0x08 > 0
    }

    private static func decodeKey(_ raw: Int, from decoder: BinaryStreamProvider) throws -> DecodingKey {
        let value = raw >> 4
        guard isStringKey(raw) else {
            return DecodingKey.intKey(value)
        }
        let stringKeyData = try decoder.getBytes(value)
        let stringKey = try String(decodeFrom: stringKeyData)
        return DecodingKey.stringKey(stringKey)
    }

    static func decode(from decoder: BinaryStreamProvider) throws -> (key: DecodingKey, dataType: DataType) {
        let raw = try decoder.getVarint()
        let dataType = try DataType(decodeFrom: raw)
        let key = try decodeKey(raw, from: decoder)
        return (key, dataType)
    }

    static func decodeProto(from decoder: BinaryStreamProvider) throws -> (key: DecodingKey, dataType: DataType) {
        let raw = try decoder.getVarint()
        let dataType = try DataType(decodeFrom: raw)
        let fieldNumber = raw >> 3
        try IntKeyWrapper.checkFieldBounds(fieldNumber)
        let key = DecodingKey.intKey(fieldNumber)
        return (key, dataType)
    }
}

extension DecodingKey: Equatable {
    
}

extension DecodingKey: Hashable {

}
