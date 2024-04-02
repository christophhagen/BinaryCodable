import Foundation

final class KeyedDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    let allKeys: [Key]

    /// - Note: The keys are not of type `Key`, since `CodingKey`s are not `Hashable`.
    /// Also, some keys found in the data may not be convertable to `Key`, e.g. the `super` key, or obsoleted keys from older implementations.
    private let elements: [DecodingKey: Data?]

    init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
        self.elements = try DecodingStorage(data: data, codingPath: codingPath).decodeKeyDataPairs()
        self.allKeys = elements.keys.compactMap { $0.asKey() }
        super.init(parentDecodedNil: true, codingPath: codingPath, userInfo: userInfo)
    }

    private func value(for intKey: Int?) -> Data?? {
        guard let intKey else {
            return nil
        }
        return elements[.integer(intKey)]
    }

    private func value(for stringKey: String) -> Data?? {
        elements[.string(stringKey)]
    }

    private func value(for key: CodingKey) throws -> Data? {
        let int = value(for: key.intValue)
        let string = value(for: key.stringValue)
        if int != nil && string != nil {
            throw DecodingError.corrupted("Found value for int and string key", codingPath: codingPath + [key])
        }
        guard let value = int ?? string else {
            throw DecodingError.notFound(key, codingPath: codingPath + [key], "Missing value for key")
        }
        return value
    }

    private func node(for key: CodingKey) throws -> DecodingNode {
        let element = try value(for: key)
        return try DecodingNode(data: element, parentDecodedNil: true, codingPath: codingPath + [key], userInfo: userInfo)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedDecodingContainer(try node(for: key).container(keyedBy: type))
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try node(for: key).unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        try node(for: SuperCodingKey())
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        try node(for: key)
    }

    func contains(_ key: Key) -> Bool {
        if let intValue = key.intValue, elements[.integer(intValue)] != .none {
            return true
        }
        return elements[.string(key.stringValue)] != .none
    }

    /**
     Decodes a null value for the given key.
     - Parameter key: The key that the decoded value is associated with.
     - Returns: Whether the encountered value was null.
     - Throws: `DecodingError.keyNotFound` if self does not have an entry for the given key.
     */
    func decodeNil(forKey key: Key) throws -> Bool {
        let element = try value(for: key)
        return element == nil
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let element = try value(for: key)
        return try decode(element: element, type: type, codingPath: codingPath + [key])
    }
}
