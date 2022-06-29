import Foundation

final class EncodingNode: AbstractEncodingNode, Encoder {
    
    var container: EncodingContainer?
    
    private func wrap<T>(container: () -> T) -> T where T: EncodingContainer {
        guard self.container == nil else {
            fatalError("Multiple calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder")
        }
        let value = container()
        self.container = value
        return value
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = wrap { KeyedEncoder<Key>(codingPath: codingPath, options: options) }
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        wrap { UnkeyedEncoder(codingPath: codingPath, options: options) }
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        wrap { ValueEncoder(codingPath: codingPath, options: options) }
    }

    func encoding<T>(_ value: T) throws -> EncodingNode where T: Encodable {
        try value.encode(to: self)
        return self
    }
}

extension EncodingNode: EncodingContainer {

    var isNil: Bool { container?.isNil ?? true }
    
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
