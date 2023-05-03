import Foundation

class EncodingNode: AbstractEncodingNode, Encoder {
    
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
        let container = wrap { KeyedEncoder<Key>(path: codingPath, info: userInfo, optional: containsOptional) }
        return KeyedEncodingContainer(container)
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        wrap { UnkeyedEncoder(path: codingPath, info: userInfo, optional: containsOptional) }
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        wrap { ValueEncoder(path: codingPath, info: userInfo, optional: containsOptional) }
    }

    func encoding<T>(_ value: T) throws -> EncodingNode where T: Encodable {
        try value.encode(to: self)
        return self
    }
}

extension EncodingNode: EncodingContainer {

    var data: Data {
        container!.data
    }

    var dataWithLengthInformationIfRequired: Data {
        container!.dataWithLengthInformationIfRequired
    }
    
    var dataType: DataType {
        container!.dataType
    }

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        guard let container else {
            // Explicitly check for nil to prevent error with unwrapping
            // when not using `encodeNil(forKey:)` for custom encoders
            return Data()
        }
        return container.encodeWithKey(key)
    }

    var isEmpty: Bool {
        container?.isEmpty ?? true
    }
}
