import Foundation

class OneOfAssociatedValuesDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    private let data: Data

    init(data: Data, path: [CodingKey], info: UserInfo) {
        self.data = data
        super.init(path: path, info: info)
    }

    var allKeys: [Key] {
        [Key(stringValue: "_0")!]
    }

    func contains(_ key: Key) -> Bool {
        return true
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        false
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        if let _ = type as? DecodablePrimitive.Type {
            if let ProtoType = type as? ProtobufDecodable.Type {
                if !data.isEmpty {
                    return try ProtoType.init(fromProtobuf: data) as! T
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
        throw ProtobufDecodingError.unsupportedType("Unexpected nested keyed container while decoding associated values of OneOf container")
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw ProtobufDecodingError.unsupportedType("Unexpected nested unkeyed container while decoding associated values of OneOf container")
    }

    func superDecoder() throws -> Decoder {
        throw ProtobufDecodingError.superNotSupported
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw ProtobufDecodingError.superNotSupported
    }
}
