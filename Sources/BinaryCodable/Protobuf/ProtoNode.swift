import Foundation

final class ProtoNode: AbstractProtoNode, Encoder {
    
    var container: ProtoContainer?
    
    private func wrap<T>(container: () -> T) -> T where T: ProtoContainer {
        let value = container()
        guard self.container == nil else {
            incompatibilityReason = "Multiple calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder"
            return value
        }
        self.container = value
        return value
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = wrap { KeyedProtoEncoder<Key>(encoding: encodedType, path: codingPath, info: userInfo) }
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        wrap { UnkeyedProtoEncoder(encoding: encodedType, path: codingPath, info: userInfo) }
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        wrap { ValueProtoEncoder(encoding: encodedType, path: codingPath, info: userInfo) }
    }

    func encoding<T>(_ value: T) throws -> ProtoNode where T: Encodable {
        try value.encode(to: self)
        return self
    }
}

extension ProtoNode: ProtoContainer {

    func protobufDefinition() throws -> String {
        if let reason = incompatibilityReason {
            throw BinaryEncodingError.notProtobufCompatible(reason)
        }
        guard let container = container else {
            throw BinaryEncodingError.notProtobufCompatible("No calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder")
        }
        return try container.protobufDefinition()
    }

    var protoTypeName: String {
        container!.protoTypeName
    }
}
