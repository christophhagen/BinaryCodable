import Foundation

final class ProtoKeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    var content = [IntKeyWrapper : NonNilEncodingContainer]()

    func assign(_ value: NonNilEncodingContainer, to key: CodingKey) throws {
        let wrapped = try IntKeyWrapper(key)
        assign(value, to: wrapped)
    }

    func assign(_ value: NonNilEncodingContainer, to key: IntKeyWrapper) {
        guard content[key] == nil else {
            fatalError("Multiple values encoded for key \(key)")
        }
        content[key] = value
    }

    func encodeNil(forKey key: Key) throws {
        throw BinaryEncodingError.nilValuesNotSupported    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let container: NonNilEncodingContainer
        if let primitive = value as? EncodablePrimitive {
            container = try EncodedPrimitive(primitive: primitive)
        } else if value is AnyDictionary {
            container = try ProtoDictEncodingNode(codingPath: codingPath, options: options).encoding(value)
        } else {
            container = try ProtoEncodingNode(codingPath: codingPath, options: options).encoding(value)
        }
        try assign(container, to: key)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        do {
            let wrapped = try IntKeyWrapper(key)
            let container = ProtoKeyedEncoder<NestedKey>(codingPath: codingPath + [key], options: options)
            assign(container, to: wrapped)
            return KeyedEncodingContainer(container)
        } catch {
            let container = ProtoKeyedThrowingEncoder<NestedKey>(error: error as! BinaryEncodingError, codingPath: codingPath, options: options)
            return KeyedEncodingContainer(container)
        }

    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        do {
            let wrapped = try IntKeyWrapper(key)
            let container = ProtoUnkeyedEncoder(codingPath: codingPath + [key], options: options)
            assign(container, to: wrapped)
            return container
        } catch {
            let container = ProtoUnkeyedThrowingEncoder(error: error as! BinaryEncodingError, codingPath: codingPath, options: options)
            return container
        }
    }

    func superEncoder() -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, codingPath: codingPath, options: options)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, codingPath: codingPath, options: options)
    }
}


extension ProtoKeyedEncoder: NonNilEncodingContainer {

    private var sortedKeysIfNeeded: [(key: CodingKeyWrapper, value: NonNilEncodingContainer)] {
        guard sortKeysDuringEncoding else {
            return content.map { $0 }
        }
        return content.sorted { $0.key < $1.key }
    }

    var combinedData: Data {
        sortedKeysIfNeeded.map { key, value -> Data in
            value.encodeWithKey(key)
        }.reduce(Data(), +)
    }

    var data: Data {
        combinedData
    }

    var dataType: DataType {
        .variableLength
    }
}
