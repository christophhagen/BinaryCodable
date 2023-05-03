import Foundation

final class KeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var content = [MixedCodingKeyWrapper : EncodingContainer]()

    override init(path: [CodingKey], info: UserInfo, optional: Bool) {
        super.init(path: path, info: info, optional: optional)
    }

    func assign(_ value: EncodingContainer, to key: CodingKey) {
        let wrapped = MixedCodingKeyWrapper(key)
        content[wrapped] = value
    }
    
    func encodeNil(forKey key: Key) throws {
        // Nothing to do, nil is ommited for keyed containers
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let container: EncodingContainer
        if value is AnyOptional {
            container = try EncodingNode(path: codingPath, info: userInfo, optional: true).encoding(value)
        } else if let primitive = value as? EncodablePrimitive {
            container = try wrapError(path: codingPath) { try EncodedPrimitive(primitive: primitive) }
        } else {
            let node = EncodingNode(
                path: codingPath,
                info: userInfo,
                optional: false)
            container = try node.encoding(value)
        }
        assign(container, to: key)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = KeyedEncoder<NestedKey>(path: codingPath + [key], info: userInfo, optional: false)
        assign(container, to: key)
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let container = UnkeyedEncoder(path: codingPath + [key], info: userInfo, optional: false)
        assign(container, to: key)
        return container
    }
    
    func superEncoder() -> Encoder {
        let container = EncodingNode(path: codingPath, info: userInfo, optional: false)
        assign(container, to: SuperEncoderKey())
        return container
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        let container = EncodingNode(path: codingPath + [key], info: userInfo, optional: false)
        assign(container, to: key)
        return container
    }
}


extension KeyedEncoder: EncodingContainer {

    var data: Data {
        if sortKeysDuringEncoding {
            return content.sorted { $0.key < $1.key }.map { $1.encodeWithKey($0) }.reduce(Data(), +)
        }
        return content.map { $1.encodeWithKey($0) }.reduce(Data(), +)
    }
    
    var dataType: DataType {
        .variableLength
    }

    var isEmpty: Bool {
        !content.values.contains { !$0.isEmpty }
    }
}
