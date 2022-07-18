import Foundation

final class OneOfEncoder: AbstractEncodingNode, Encoder {
    
    var container: OneOfKeyedContainer?
    
    func wrap<T>(container: () -> T) -> T where T: OneOfKeyedContainer {
        guard self.container == nil else {
            fatalError("Multiple calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder")
        }
        let value = container()
        self.container = value
        return value
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        guard self.container == nil else {
            fatalError("Multiple calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder")
        }
        let container = OneOfKeyedEncoder<Key>(path: codingPath, info: userInfo)
        self.container = container
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        ProtoUnkeyedThrowingEncoder(error: .unsupportedType("ProtobufOneOf can't be applied to unkeyed containers"), path: codingPath, info: userInfo)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        ProtoValueThrowingEncoder(error: .unsupportedType("ProtobufOneOf can't be applied to single value containers"), path: codingPath, info: userInfo)
    }

    func encoding<T>(_ value: T) throws -> (key: IntKeyWrapper, value: NonNilEncodingContainer) where T: Encodable {
        try value.encode(to: self)
        guard let container = container else {
            throw ProtobufEncodingError.noContainersAccessed
        }
        return try container.getContent()
    }
}
