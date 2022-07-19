import Foundation

/**
 A protocol to abstract a `OneOfKeyedEncoder`, which can't be directly stored due to the associated type.
 */
protocol OneOfKeyedContainer {
    
    func getContent() throws -> (key: IntKeyWrapper, value: NonNilEncodingContainer)
}

/**
 A keyed encoder specifically to encode a `ProtobufOneOf` enum case and associated value.

 The encoder is wrapped by `OneOfEncodingNoder`, and itself wraps a `OneOfAssociatedValuesEncoder`.

 The encoder expects a single call to `nestedContainer(keyedBy:forKey:)`, all other access will fail.
 */
final class OneOfKeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    /// The encoded data consisting of the enum case, and the associated value.
    private var content: (key: IntKeyWrapper, value: OneOfAssociatedValuesContainer)?

    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.invalidAccess("Unexpected call to `encodeNil(forKey:)` while encoding a `ProtobufOneOf` enum")
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        throw ProtobufEncodingError.invalidAccess("Unexpected call to `encode(_,forKey:)` while encoding a `ProtobufOneOf` enum")
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        do {
            let wrapped = try IntKeyWrapper(key)
            let container = OneOfAssociatedValuesEncoder<NestedKey>(path: codingPath + [key], info: userInfo)
            content = (wrapped, container)
            return KeyedEncodingContainer(container)
        } catch {
            let container = ProtoKeyedThrowingEncoder<NestedKey>(error: error as! ProtobufEncodingError,
                                                                 path: codingPath + [key],
                                                                 info: userInfo)
            return KeyedEncodingContainer(container)
        }
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = ProtoUnkeyedThrowingEncoder(
            error: .invalidAccess("Unexpected call to `encode(_,forKey:)` while encoding a `ProtobufOneOf` enum"),
            path: codingPath + [key], info: userInfo)
        return container
    }
    
    func superEncoder() -> Encoder {
        ProtoThrowingNode(
            error: .invalidAccess("Unexpected call to `superEncoder()` while encoding a `ProtobufOneOf` enum"),
            path: codingPath, info: userInfo)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        ProtoThrowingNode(
            error: .invalidAccess("Unexpected call to `superEncoder(forKey:)` while encoding a `ProtobufOneOf` enum"),
            path: codingPath, info: userInfo)
    }
}

extension OneOfKeyedEncoder: OneOfKeyedContainer {
    
    func getContent() throws -> (key: IntKeyWrapper, value: NonNilEncodingContainer) {
        guard let content = content else {
            throw ProtobufEncodingError.noContainersAccessed
        }
        let value = try content.value.getValue()
        return (content.key, value)
    }
}
