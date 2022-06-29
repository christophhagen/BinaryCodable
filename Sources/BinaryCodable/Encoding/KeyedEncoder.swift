import Foundation

final class KeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var content = [CodingKeyWrapper : EncodingContainer]()
    
    @discardableResult
    func assign<T>(to key: CodingKey, container: () throws -> T) rethrows -> T where T: EncodingContainer {
        if forceProtobufCompatibility && key.intValue == nil {
            // Protobuf requires integer keys
            fatalError("Protobuf compatibility requires integer keys")
        }
        let wrapped = CodingKeyWrapper(key)
        guard content[wrapped] == nil else {
            fatalError("Multiple values encoded for key \(key)")
        }
        let value = try container()
        content[wrapped] = value
        return value
    }
    
    func encodeNil(forKey key: Key) throws {
        // Nothing to do, nil is ommited for keyed containers
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            try assign(to: key) {
                try EncodedPrimitive(primitive: primitive, protobuf: forceProtobufCompatibility)
            }
            return
        }
        try assign(to: key) {
            try EncodingNode(codingPath: codingPath, options: options).encoding(value)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign(to: key) {
            KeyedEncoder<NestedKey>(codingPath: codingPath + [key], options: options)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        assign(to: key) {
            UnkeyedEncoder(codingPath: codingPath + [key], options: options)
        }
    }
    
    func superEncoder() -> Encoder {
        failIfProto("Protobuf compatibility does not support encoding super")
        return assign(to: SuperEncoderKey()) {
            EncodingNode(codingPath: codingPath, options: options)
        }
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        failIfProto("Protobuf compatibility does not support encoding super")
        return assign(to: key) {
            EncodingNode(codingPath: codingPath + [key], options: options)
        }
    }
}


extension KeyedEncoder: EncodingContainer {

    /// Sort keys so that output is deterministic
    private var sortedData: Data {
        content
            .sorted { $0.key < $1.key }
            .map { key, value -> Data in
            key.encode(for: value.dataType) + value.dataWithLengthInformationIfRequired
        }.reduce(Data(), +)
    }

    private var unsortedData: Data {
        content
            .map { key, value -> Data in
            key.encode(for: value.dataType) + value.dataWithLengthInformationIfRequired
        }.reduce(Data(), +)
    }
    
    var data: Data {
        sortKeysDuringEncoding ? sortedData : unsortedData
    }
    
    var dataType: DataType {
        .variableLength
    }
}

extension KeyedEncoder: CustomStringConvertible {
    
    var description: String {
        "Keyed\n" + content.map { key, value in
            key.description + "\n" + "\(value)".indented()
        }.joined(separator: "\n").indented()
    }
}
