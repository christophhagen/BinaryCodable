import Foundation

typealias KeyedDataCallback = ((CodingKey) -> Data?)

class OneOfDecodingNode: AbstractDecodingNode, Decoder {

    private let content: [DecodingKey: Data]
    
    init(content: [DecodingKey: Data], path: [CodingKey], info: UserInfo) {
        self.content = content
        super.init(path: path, info: info)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = OneOfKeyedDecoder<Key>(content: content, path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw ProtobufDecodingError.unsupportedType("Unexpected unkeyed container in OneOf type")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw ProtobufDecodingError.unsupportedType("Unexpected single value container in OneOf type")
    }
}
