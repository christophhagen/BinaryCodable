import Foundation

final class KeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var encodedValues: [HashableKey : EncodableContainer] = [:]

    /// Internal indicator to prevent assigning a single key multiple times
    private var multiplyAssignedKey: HashableKey? = nil

    @discardableResult
    private func assign<T>(_ value: T, forKey key: CodingKey) -> T where T: EncodableContainer {
        let hashableKey = HashableKey(key: key)
        if encodedValues[hashableKey] != nil {
            multiplyAssignedKey = hashableKey
        } else {
            encodedValues[hashableKey] = value
        }
        return value
    }

    private func assignedNode(forKey key: CodingKey) -> EncodingNode {
        let node = EncodingNode(needsLengthData: true, codingPath: codingPath + [key], userInfo: userInfo)
        return assign(node, forKey: key)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        // By wrapping the nested container in a node, it adds length information to it
        return KeyedEncodingContainer(assignedNode(forKey: key).container(keyedBy: keyType))
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        // By wrapping the nested container in a node, it adds length information to it
        return assignedNode(forKey: key).unkeyedContainer()
    }

    func superEncoder() -> Encoder {
        return assignedNode(forKey: SuperCodingKey())
    }

    func superEncoder(forKey key: Key) -> Encoder {
        return assignedNode(forKey: key)
    }

    func encodeNil(forKey key: Key) throws {
        assign(NilContainer(), forKey: key)
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let encoded = try encodeValue(value, needsLengthData: true)
        assign(encoded, forKey: key)
    }
}

extension KeyedEncoder: EncodableContainer {

    var needsNilIndicator: Bool {
        false
    }

    var isNil: Bool {
        false
    }

    func containedData() throws -> Data {
        if let multiplyAssignedKey {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "Multiple values assigned to key \(multiplyAssignedKey)"))
        }
        guard sortKeysDuringEncoding else {
            return try encode(elements: encodedValues)
        }
        return try encode(elements: encodedValues.sorted { $0.key < $1.key })
    }

    private func encode<T>(elements: T) throws -> Data where T: Collection, T.Element == (key: HashableKey, value: EncodableContainer) {
        try elements.map { key, value in
            try value.completeData(with: key.key, codingPath: codingPath)
        }.joinedData
    }
}
