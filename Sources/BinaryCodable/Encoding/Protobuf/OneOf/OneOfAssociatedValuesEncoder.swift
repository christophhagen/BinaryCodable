import Foundation

/**
 A protocol to abstract a `OneOfAssociatedValuesEncoder`, which can't be directly stored due to its associated type.
 */
protocol OneOfAssociatedValuesContainer {
    
    func getValue() throws -> EncodingContainer
}

/**
 A container to specifically encode the associated value of a `ProtobufOneOf` enum case.

 The container ignores the associated values key `_0` and only encodes the value.

 The container only allows a single call to `encode(_,forKey:)`, all other access will fail.
 */
final class OneOfAssociatedValuesEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    /// The encoded associated value
    var value: EncodingContainer?

    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.invalidAccess(
            "Unexpected call to `encodeNil(forKey:)` while encoding a `ProtobufOneOf` associated value")
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        guard self.value == nil else {
            throw ProtobufEncodingError.invalidAccess(
                "Multiple calls to `encode(_,forKey:)` while encoding a `ProtobufOneOf` associated value")
        }

        if let primitive = value as? EncodablePrimitive {
            self.value = try EncodedPrimitive(protobuf: primitive, excludeDefaults: false)
        } else if value is AnyDictionary {
            self.value = try ProtoDictEncodingNode(path: codingPath, info: userInfo, optional: false).encoding(value)
        } else {
            self.value = try ProtoEncodingNode(path: codingPath, info: userInfo, optional: false).encoding(value)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ProtoKeyedThrowingEncoder<NestedKey>(
            error: .invalidAccess("Unexpected call to `nestedContainer(keyedBy:forKey:)` while encoding a `ProtobufOneOf` associated value"),
            path: codingPath + [key], info: userInfo)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = ProtoUnkeyedThrowingEncoder(
            error: .invalidAccess("Unexpected call to `nestedUnkeyedContainer(forKey:)` while encoding a `ProtobufOneOf` associated value"),
            path: codingPath + [key], info: userInfo)
        return container
    }
    
    func superEncoder() -> Encoder {
        ProtoThrowingNode(
            error: .invalidAccess("Unexpected call to `superEncoder()` while encoding a `ProtobufOneOf` associated value"),
            path: codingPath, info: userInfo)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        ProtoThrowingNode(
            error: .invalidAccess("Unexpected call to `superEncoder(forKey:)` while encoding a `ProtobufOneOf` associated value"),
            path: codingPath, info: userInfo)
    }
}

extension OneOfAssociatedValuesEncoder: OneOfAssociatedValuesContainer {
    
    func getValue() throws -> EncodingContainer {
        guard let value = value else {
            throw ProtobufEncodingError.noContainersAccessed
        }
        return value
    }
}
