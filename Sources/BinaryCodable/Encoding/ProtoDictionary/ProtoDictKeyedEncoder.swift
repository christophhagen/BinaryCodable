import Foundation

final class ProtoDictKeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var content = [NonNilEncodingContainer]()

    func assign(_ value: NonNilEncodingContainer, to key: NonNilEncodingContainer) {
        let pair = ProtoDictPair(key: key, value: value)
        content.append(pair)
    }

    func encodeNil(forKey key: Key) throws {
        throw BinaryEncodingError.nilValuesNotSupported
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let container: NonNilEncodingContainer
        if let primitive = value as? EncodablePrimitive {
            container = try EncodedPrimitive(protobuf: primitive)
        } else {
            container = try ProtoEncodingNode(codingPath: codingPath, options: options).encoding(value)
        }
        let wrapped = try EncodedPrimitive(protobuf: key.intValue ?? key.stringValue)
        assign(container, to: wrapped)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        do {
            let wrapped = try EncodedPrimitive(protobuf: key.intValue ?? key.stringValue)
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
            let wrapped = try EncodedPrimitive(protobuf: key.intValue ?? key.stringValue)
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


extension ProtoDictKeyedEncoder: NonNilEncodingContainer {

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        content
            .map { $0.encodeWithKey(key) }
            .joinedData
    }

    var data: Data {
        content.map { $0.dataWithLengthInformationIfRequired }.joinedData
    }

    var dataType: DataType {
        .variableLength
    }
}
