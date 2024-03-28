import Foundation

/**
 A keyed decoder specifically to decode the associated value within a `ProtobufOneOf` type.

 The decoder receives the data associated with the enum case from `OneOfKeyedDecoder`,
 and allows exactly one associated value key (`_0`) to be decoded from the data.

 The decoder allows only one call to `decode(_:forKey:)`, all other access will fail.
 */
final class OneOfAssociatedValuesDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    private let data: Data

    init(data: Data, path: [CodingKey], info: UserInfo) {
        self.data = data
        super.init(codingPath: path, userInfo: info)
    }

    var allKeys: [Key] {
        [Key(stringValue: "_0")!]
    }

    func contains(_ key: Key) -> Bool {
        return true
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `decodeNil(forKey:)` while decoding associated value for a `ProtobufOneOf` type")
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        if let _ = type as? DecodablePrimitive.Type {
            if let ProtoType = type as? ProtobufDecodable.Type {
                if !data.isEmpty {
                    return try ProtoType.init(fromProtobuf: data, path: codingPath + [key]) as! T
                } else {
                    return ProtoType.zero as! T
                }
            }
            throw ProtobufDecodingError.unsupported(type: type)
        } else if type is AnyDictionary.Type {
            let node = ProtoDictDecodingNode(data: data, path: codingPath, info: userInfo)
            return try T.init(from: node)
        }
        let node = ProtoDecodingNode(data: data, path: codingPath, info: userInfo)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `nestedContainer(keyedBy:forKey:)` while decoding associated value for a `ProtobufOneOf` type")
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `nestedUnkeyedContainer(forKey:)` while decoding associated value for a `ProtobufOneOf` type")
    }

    func superDecoder() throws -> Decoder {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `superDecoder()` while decoding associated value for a `ProtobufOneOf` type")
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw ProtobufDecodingError.invalidAccess(
            "Unexpected call to `superDecoder(forKey:)` while decoding associated value for a `ProtobufOneOf` type")
    }
}
