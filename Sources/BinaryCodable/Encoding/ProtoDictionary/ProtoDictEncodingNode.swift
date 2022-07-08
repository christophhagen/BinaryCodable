import Foundation

final class ProtoDictEncodingNode: ProtoEncodingNode {

    override func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = wrap { ProtoDictKeyedEncoder<Key>(path: codingPath, info: userInfo) }
        return KeyedEncodingContainer(container)
    }

    override func unkeyedContainer() -> UnkeyedEncodingContainer {
        wrap { ProtoDictUnkeyedEncoder(path: codingPath, info: userInfo) }
    }
}
