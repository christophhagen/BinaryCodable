import Foundation

final class ProtoKeyedThrowingEncoder<Key>: ProtoThrowingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    func encodeNil(forKey key: Key) throws {
        throw error
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        throw error
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ProtoKeyedThrowingEncoder<NestedKey>(from: self)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        ProtoUnkeyedThrowingEncoder(from: self)
    }

    func superEncoder() -> Encoder {
        ProtoThrowingNode(from: self)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        ProtoThrowingNode(from: self)
    }
}
