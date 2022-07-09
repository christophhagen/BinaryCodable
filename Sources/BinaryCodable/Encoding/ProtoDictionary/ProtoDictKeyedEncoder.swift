import Foundation

final class ProtoDictKeyedEncoder<Key>: AbstractEncodingNode, KeyedEncodingContainerProtocol where Key: CodingKey {

    private var content = [NonNilEncodingContainer]()

    func assign(_ value: NonNilEncodingContainer, to key: NonNilEncodingContainer) {
        let pair = ProtoDictPair(key: key, value: value)
        content.append(pair)
    }

    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.nilValuesNotSupported
    }

    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        let container: NonNilEncodingContainer
        if let primitive = value as? EncodablePrimitive {
            container = try EncodedPrimitive(protobuf: primitive)
        } else {
            container = try ProtoEncodingNode(path: codingPath, info: userInfo).encoding(value)
        }
        let wrapped = try EncodedPrimitive(protobuf: key.intValue ?? key.stringValue)
        assign(container, to: wrapped)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        do {
            let wrapped = try EncodedPrimitive(protobuf: key.intValue ?? key.stringValue)
            let container = ProtoKeyedEncoder<NestedKey>(path: codingPath + [key], info: userInfo)
            assign(container, to: wrapped)
            return KeyedEncodingContainer(container)
        } catch {
            let container = ProtoKeyedThrowingEncoder<NestedKey>(
                error: error as! ProtobufEncodingError,
                path: codingPath,
                info: userInfo)
            return KeyedEncodingContainer(container)
        }
    }

    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        do {
            let wrapped = try EncodedPrimitive(protobuf: key.intValue ?? key.stringValue)
            let container = ProtoUnkeyedEncoder(path: codingPath + [key], info: userInfo)
            assign(container, to: wrapped)
            return container
        } catch {
            let container = ProtoUnkeyedThrowingEncoder(
                error: error as! ProtobufEncodingError,
                path: codingPath,
                info: userInfo)
            return container
        }
    }

    func superEncoder() -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, path: codingPath, info: userInfo)
    }

    func superEncoder(forKey key: Key) -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, path: codingPath, info: userInfo)
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

    var isEmpty: Bool {
        !content.contains { !$0.isEmpty }
    }
}
