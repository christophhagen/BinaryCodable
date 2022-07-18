import Foundation

protocol OneOfKeyedContainer {
    
    func getContent() throws -> (key: IntKeyWrapper, value: NonNilEncodingContainer)
}

final class OneOfKeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var content: (key: IntKeyWrapper, value: OneOfAssociatedValuesContainer)?

    func encodeNil(forKey key: Key) throws {
        // Nothing to do, nil is ommited for keyed containers
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        throw ProtobufEncodingError.unsupportedType("Expected keyed container call for OneOf definition")
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
        let container = ProtoUnkeyedThrowingEncoder(error: .unsupportedType("Nested unkeyed containers not supported for OneOf types"), path: codingPath + [key], info: userInfo)
        return container
    }
    
    func superEncoder() -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, path: codingPath, info: userInfo)
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, path: codingPath, info: userInfo)
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
