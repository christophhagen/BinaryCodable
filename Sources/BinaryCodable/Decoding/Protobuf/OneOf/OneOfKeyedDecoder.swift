import Foundation

/**
 A keyed decoder specifically to decode an enum of type `ProtobufOneOf`.

 The decoder only allows a call to `nestedContainer(keyedBy:forKey:)`
 to decode the associated value of the `OneOf`, all other access will fail with an error.

 The decoder receives all key-value pairs from the parent node (passed through `OneOfDecodingNode`),
 in order to select the appropriate data required to decode the enum (`OneOf` types share the field values with the enclosing message).
 */
final class OneOfKeyedDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

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

    func decodeNil(forKey key: Key) throws -> Bool {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `decodeNil(forKey:)` while decoding `ProtobufOneOf` enum")
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `decode(_,forKey)` while decoding `ProtobufOneOf` enum")
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let data = content.first(where: { $0.key.isEqual(to: key) })?.value ?? Data()
        let container = OneOfAssociatedValuesDecoder<NestedKey>(data: data, path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `nestedUnkeyedContainer(forKey:)` while decoding `ProtobufOneOf` enum")
    }

    func superDecoder() throws -> Decoder {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `superDecoder()` while decoding `ProtobufOneOf` enum")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `superDecoder(forKey:)` while decoding `ProtobufOneOf` enum")
    }
}
