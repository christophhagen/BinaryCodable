import Foundation

final class KeyedEncoder<Key>: KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    var content = [CodingKeyWrapper : EncodingContainer]()
    
    init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    @discardableResult
    func assign<T>(to key: CodingKey, container: () throws -> T) rethrows -> T where T: EncodingContainer {
        let wrapped = CodingKeyWrapper(codingKey: key)
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
    
    #warning("Signal super encoding")
    func superEncoder() -> Encoder {
        assign(to: SuperEncoderKey()) {
            EncodingNode(codingPath: codingPath, userInfo: userInfo)
        }
    }
    
    #warning("Signal super encoding")
    func superEncoder(forKey key: Key) -> Encoder {
        assign(to: key) {
            EncodingNode(codingPath: codingPath + [key], userInfo: userInfo)
        }
    }
}


extension KeyedEncoder: EncodingContainer {
    
    var data: Data {
        #warning("Implement")
        return Data()
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
