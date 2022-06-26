import Foundation

final class KeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var content = [CodingKeyWrapper : EncodingContainer]()
    
    @discardableResult
    func assign<T>(to key: CodingKey, container: () throws -> T) rethrows -> T where T: EncodingContainer {
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
                try EncodedPrimitive(primitive: primitive)
            }
            return
        }
        try assign(to: key) {
            try EncodingNode(codingPath: codingPath, userInfo: userInfo).encoding(value)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign(to: key) {
            KeyedEncoder<NestedKey>(codingPath: codingPath + [key], userInfo: userInfo)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        assign(to: key) {
            UnkeyedEncoder(codingPath: codingPath + [key], userInfo: userInfo)
        }
    }
    
    func superEncoder() -> Encoder {
        assign(to: SuperEncoderKey()) {
            EncodingNode(codingPath: codingPath, userInfo: userInfo)
        }
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        assign(to: key) {
            EncodingNode(codingPath: codingPath + [key], userInfo: userInfo)
        }
    }
}


extension KeyedEncoder: EncodingContainer {
    
    var data: Data {
        content.map { key, value -> Data in
            key.encode(for: value.dataType) + value.dataWithLengthInformationIfRequired
        }.reduce(Data(), +)
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
