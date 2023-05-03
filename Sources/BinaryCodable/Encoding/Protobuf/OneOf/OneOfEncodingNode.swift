import Foundation

/**
 An encoding node specifically to encode `ProtobufOneOf` types, which require adjustments to the encoding process.

 The node wraps a `OneOfKeyedEncoder`, which encodes the enum case and associated value.

 The node allows only one call to `container(keyedBy:)`, all other access will fail.
 */
final class OneOfEncodingNode: AbstractEncodingNode, Encoder {

    /// The wrapped container encoding the enum case and associated value
    var container: OneOfKeyedContainer?

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        guard self.container == nil else {
            fatalError("Multiple calls to `container<>(keyedBy:)` while encoding a `ProtobufOneOf` type")
        }
        let container = OneOfKeyedEncoder<Key>(path: codingPath, info: userInfo, optional: false)
        self.container = container
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        ProtoUnkeyedThrowingEncoder(
            error: .invalidAccess("Unexpected call to `unkeyedContainer()` while encoding a `ProtobufOneOf` type"),
            path: codingPath, info: userInfo)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        ProtoValueThrowingEncoder(
            error: .invalidAccess("Unexpected call to `singleValueContainer()` while encoding a `ProtobufOneOf` type"),
            path: codingPath, info: userInfo)
    }

    func encoding<T>(_ value: T) throws -> (key: IntKeyWrapper, value: EncodingContainer) where T: Encodable {
        try value.encode(to: self)
        guard let container = container else {
            throw ProtobufEncodingError.noContainersAccessed
        }
        return try container.getContent()
    }
}
