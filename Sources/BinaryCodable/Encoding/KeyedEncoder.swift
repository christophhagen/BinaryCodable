import Foundation

final class KeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var content = [MixedCodingKeyWrapper : EncodingContainer]()

    func assign(_ value: EncodingContainer, to key: CodingKey) {
        let wrapped = MixedCodingKeyWrapper(key)
        content[wrapped] = value
    }
    
    func encodeNil(forKey key: Key) throws {
        // Nothing to do, nil is ommited for keyed containers
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let container: EncodingContainer
        if let primitive = value as? EncodablePrimitive {
            container = try EncodedPrimitive(primitive: primitive)
        } else {
            container = try EncodingNode(path: codingPath, info: userInfo).encoding(value)
        }
        assign(container, to: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = KeyedEncoder<NestedKey>(path: codingPath + [key], info: userInfo)
        assign(container, to: key)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = UnkeyedEncoder(path: codingPath + [key], info: userInfo)
        assign(container, to: key)
        return container
    }
    
    func superEncoder() -> Encoder {
        let container = EncodingNode(path: codingPath, info: userInfo)
        assign(container, to: SuperEncoderKey())
        return container
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        let container = EncodingNode(path: codingPath + [key], info: userInfo)
        assign(container, to: key)
        return container
    }
}


extension KeyedEncoder: EncodingContainer {

    private var sortedKeysIfNeeded: [(key: CodingKeyWrapper, value: EncodingContainer)] {
        guard sortKeysDuringEncoding else {
            return content.map { $0 }
        }
        return content.sorted { $0.key < $1.key }
    }

    var data: Data {
        sortedKeysIfNeeded.map { key, value -> Data in
            value.encodeWithKey(key)
        }.reduce(Data(), +)
    }
    
    var dataType: DataType {
        .variableLength
    }

    var isEmpty: Bool {
        !content.values.contains { !$0.isEmpty }
    }
}
