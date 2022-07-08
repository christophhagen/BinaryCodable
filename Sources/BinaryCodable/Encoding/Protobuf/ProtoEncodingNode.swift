import Foundation

class ProtoEncodingNode: AbstractEncodingNode, Encoder {

    var container: NonNilEncodingContainer?

    func wrap<T>(container: () -> T) -> T where T: NonNilEncodingContainer {
        guard self.container == nil else {
            fatalError("Multiple calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder")
        }
        let value = container()
        self.container = value
        return value
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = wrap { ProtoKeyedEncoder<Key>(codingPath: codingPath, options: options) }
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        wrap { ProtoUnkeyedEncoder(codingPath: codingPath, options: options) }
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        wrap { ProtoValueEncoder(codingPath: codingPath, options: options) }
    }

    func encoding<T>(_ value: T) throws -> Self where T: Encodable {
        try value.encode(to: self)
        return self
    }
}

extension ProtoEncodingNode: NonNilEncodingContainer {

    var data: Data {
        container!.data
    }

    var dataType: DataType {
        container!.dataType
    }

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        container!.encodeWithKey(key)
    }
}
