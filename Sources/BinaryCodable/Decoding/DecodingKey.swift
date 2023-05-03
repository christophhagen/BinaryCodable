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

    private static func decodeKey(_ raw: Int, from decoder: BinaryStreamProvider, path: [CodingKey]) throws -> DecodingKey {
        let value = raw >> 4
        guard isStringKey(raw) else {
            return DecodingKey.intKey(value)
        }
        guard value >= 0 else {
            throw DecodingError.invalidDataSize(path)
        }
        let stringKeyData = try decoder.getBytes(value, path: path)
        let stringKey = try String(decodeFrom: stringKeyData, path: path)
        return DecodingKey.stringKey(stringKey)
    }

    static func decode(from decoder: BinaryStreamProvider, path: [CodingKey]) throws -> (key: DecodingKey, dataType: DataType) {
        let raw = try decoder.getVarint(path: path)
        let dataType = try DataType(decodeFrom: raw, path: path)
        let key = try decodeKey(raw, from: decoder, path: path)
        return (key, dataType)
    }

    static func decodeProto(from decoder: BinaryStreamProvider, path: [CodingKey]) throws -> (key: DecodingKey, dataType: DataType) {
        let raw = try decoder.getVarint(path: path)
        let dataType = try DataType(decodeFrom: raw, path: path)
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

extension DecodingKey: CustomStringConvertible {

    var description: String {
        switch self {
        case .intKey(let value):
            return "\(value)"
        case .stringKey(let value):
            return value
        }
    }
}
