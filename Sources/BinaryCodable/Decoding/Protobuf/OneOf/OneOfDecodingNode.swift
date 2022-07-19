import Foundation

typealias KeyedDataCallback = ((CodingKey) -> Data?)

/**
 A decoding node specifically to decode protobuf `OneOf` structures.

 The node receives all data from the parent container, and hands it to a `OneOfKeyedDecoder`,
 which then decodes the keyed values within the enum.

 Attempts to access other containers (`keyed` or `single`) will throw an error.
 */
final class OneOfDecodingNode: AbstractDecodingNode, Decoder {

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
        throw ProtobufDecodingError.invalidAccess(
            "Attempt to access unkeyedContainer() for a type conforming to ProtobufOneOf")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw ProtobufDecodingError.invalidAccess(
            "Attempt to access singleValueContainer() for a type conforming to ProtobufOneOf")
    }
}
