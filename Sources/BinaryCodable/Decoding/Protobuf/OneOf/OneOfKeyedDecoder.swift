import Foundation

class OneOfKeyedDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    private let content: [DecodingKey: Data]

    init(content: [DecodingKey: Data], path: [CodingKey], info: UserInfo) {
        self.content = content
        super.init(path: path, info: info)
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

    private func getDataIfAvailable(forKey key: CodingKey) -> Data? {
        content.first(where: { $0.key.isEqual(to: key) })?.value
    }

    func getData(forKey key: CodingKey) -> Data {
        getDataIfAvailable(forKey: key) ?? Data()
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        !contains(key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        throw ProtobufDecodingError.unsupportedType("Unexpected decode while decoding OneOf")
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let data = getData(forKey: key)
        let container = OneOfAssociatedValuesDecoder<NestedKey>(data: data, path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw ProtobufDecodingError.unsupportedType("Unexpected nested unkeyed container while decoding OneOf")
    }

    func superDecoder() throws -> Decoder {
        throw ProtobufDecodingError.superNotSupported
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw ProtobufDecodingError.superNotSupported
    }
}
