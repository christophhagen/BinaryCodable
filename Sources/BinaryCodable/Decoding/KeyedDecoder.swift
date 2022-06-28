import Foundation

private func decodeData(_ data: Data) throws -> [DecodingKey : Data] {
    let decoder = DataDecoder(data: data)
    var content = [DecodingKey: Data]()
    while decoder.hasMoreBytes {
        let raw = try decoder.getVarint()
        let rawDataType = (raw >> 1) & 7
        guard let dataType = DataType(rawValue: rawDataType) else {
            throw BinaryDecodingError.unknownDataType(rawDataType)
        }

        let value = raw >> 4
        let key: DecodingKey
        if raw & 1 == 1 {
            // String key
            let stringKeyData = try decoder.getBytes(value)
            let stringKey = try String(decodeFrom: stringKeyData)
            key = DecodingKey.stringKey(stringKey)
        } else {
            // Int key
            key = DecodingKey.intKey(value)
        }

        let data = try decoder.getData(for: dataType)
        content[key] = data
    }
    return content
}

final class KeyedDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    let content: [DecodingKey: Data]

    init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
        self.content = try decodeData(data)
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    var allKeys: [Key] {
        content.keys.compactMap { key in
            switch key {
            case .intKey(let value):
                return Key(intValue: value)
            case .stringKey(let value):
                return Key(stringValue: value)
            }
        }
    }

    func contains(_ key: Key) -> Bool {
        content.keys.contains { $0.isEqual(to: key) }
    }

    private func getData(forKey key: CodingKey) throws -> Data {
        guard let data = content.first(where: { $0.key.isEqual(to: key) })?.value else {
            throw BinaryDecodingError.missingDataForKey(key)
        }
        return data
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        !contains(key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let data = try getData(forKey: key)
        if let Primitive = type as? DecodablePrimitive.Type {
            return try Primitive.init(decodeFrom: data) as! T
        }
        let node = DecodingNode(data: data, codingPath: codingPath, userInfo: userInfo)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let data = try getData(forKey: key)
        let container = try KeyedDecoder<NestedKey>(data: data, codingPath: codingPath, userInfo: userInfo)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let data = try getData(forKey: key)
        return try UnkeyedDecoder(data: data, codingPath: codingPath, userInfo: userInfo)
    }

    func superDecoder() throws -> Decoder {
        let data = try getData(forKey: SuperEncoderKey())
        return DecodingNode(data: data, codingPath: codingPath, userInfo: userInfo)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        let data = try getData(forKey: key)
        return DecodingNode(data: data, codingPath: codingPath, userInfo: userInfo)
    }
}
