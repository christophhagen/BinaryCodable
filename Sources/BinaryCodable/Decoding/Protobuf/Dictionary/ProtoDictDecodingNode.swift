import Foundation

final class ProtoDictDecodingNode: ProtoDecodingNode {

    override func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try ProtoDictKeyedDecoder<Key>(data: storage.useAsData(), codingPath: codingPath, options: options)
        return KeyedDecodingContainer(container)
    }

    override func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try ProtoDictUnkeyedDecoder(data: storage.useAsData(), codingPath: codingPath, options: options)
    }
}
