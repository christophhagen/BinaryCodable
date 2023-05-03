import Foundation

class ProtoEncodingNode: AbstractEncodingNode, Encoder {

    var container: EncodingContainer?

    func wrap<T>(container: () -> T) -> T where T: EncodingContainer {
        guard self.container == nil else {
            fatalError("Multiple calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder")
        }
        let value = container()
        self.container = value
        return value
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = wrap { ProtoKeyedEncoder<Key>(path: codingPath, info: userInfo, optional: false) }
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        wrap { ProtoUnkeyedEncoder(path: codingPath, info: userInfo, optional: false) }
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        wrap { ProtoValueEncoder(path: codingPath, info: userInfo, optional: false) }
    }

    func encoding<T>(_ value: T) throws -> Self where T: Encodable {
        try value.encode(to: self)
        return self
    }
}

extension ProtoEncodingNode: EncodingContainer {

    var data: Data {
        container!.data
    }

    var dataType: DataType {
        container!.dataType
    }

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        container!.encodeWithKey(key)
    }

    var isEmpty: Bool {
        container?.isEmpty ?? true
    }
}
