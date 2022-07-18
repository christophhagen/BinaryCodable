import Foundation

protocol OneOfAssociatedValuesContainer {
    
    func getValue() throws -> NonNilEncodingContainer
}

final class OneOfAssociatedValuesEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var value: NonNilEncodingContainer?

    func assign(_ value: NonNilEncodingContainer) throws {
        guard self.value == nil else {
            throw ProtobufEncodingError.unsupportedType("Multiple values encoded in OneOf container")
        }
        self.value = value
    }
    
    func encodeNil(forKey key: Key) throws {
        // Nothing to do, nil is ommited for keyed containers
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let container: NonNilEncodingContainer
        if let primitive = value as? EncodablePrimitive {
            container = try EncodedPrimitive(protobuf: primitive, excludeDefaults: true)
        } else if value is AnyDictionary {
            container = try ProtoDictEncodingNode(path: codingPath, info: userInfo).encoding(value)
        } else {
            container = try ProtoEncodingNode(path: codingPath, info: userInfo).encoding(value)
        }
        try assign(container)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ProtoKeyedThrowingEncoder<NestedKey>(error: .unsupportedType("Too much nesting for OneOf type"), path: codingPath + [key], info: userInfo)
        return KeyedEncodingContainer(container)
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

extension OneOfAssociatedValuesEncoder: OneOfAssociatedValuesContainer {
    
    func getValue() throws -> NonNilEncodingContainer {
        guard let value = value else {
            throw ProtobufEncodingError.noContainersAccessed
        }
        return value
    }
}
