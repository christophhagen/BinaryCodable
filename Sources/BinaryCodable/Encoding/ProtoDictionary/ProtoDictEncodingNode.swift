import Foundation

final class ProtoDictEncodingNode: ProtoEncodingNode {

    override func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = wrap { ProtoDictKeyedEncoder<Key>(codingPath: codingPath, options: options) }
        return KeyedEncodingContainer(container)
    }

    override func unkeyedContainer() -> UnkeyedEncodingContainer {
        wrap { ProtoDictUnkeyedEncoder(codingPath: codingPath, options: options) }
    }
}
