import Foundation

struct KeyedEncoder<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {

    let storage: KeyedEncoderStorage

    init(storage: KeyedEncoderStorage) {
        self.storage = storage
    }

    var codingPath: [any CodingKey] {
        storage.codingPath
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        // By wrapping the nested container in a node, it adds length information to it
        let node = storage.assignedNode(forKey: key)
        return KeyedEncodingContainer(node.container(keyedBy: keyType))
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        // By wrapping the nested container in a node, it adds length information to it
        storage.assignedNode(forKey: key).unkeyedContainer()
    }

    func superEncoder() -> Encoder {
        storage.assignedNode(forKey: SuperCodingKey())
    }

    func superEncoder(forKey key: Key) -> Encoder {
        storage.assignedNode(forKey: key)
    }

    func encodeNil(forKey key: Key) throws {
        // If a value is nil, then it is not encoded
        // This is not consistent with the documentation of `decodeNil(forKey:)`,
        // which states that when decodeNil() should fail if the key is not present.
        // We could fix this by explicitly assigning a `nil` value:
        // `assign(NilContainer(), forKey: key)`
        // But this would cause other problems, either breaking the decoding of double optionals (e.g. Int??),
        // Or by requiring an additional `nil` indicator for ALL values in keyed containers,
        // which would make the format a lot less efficient
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        try storage.encode(value, forKey: key)
    }
}
