import Foundation

final class ProtoDictUnkeyedEncoder: AbstractEncodingNode, UnkeyedEncodingContainer {

    var count: Int {
        content.count
    }

    private var content = [ProtoDictPair]()

    private var key: EncodingContainer?

    private func assign<T>(_ value: T) where T: EncodingContainer {
        if let key = key {
            let pair = ProtoDictPair(key: key, value: value)
            content.append(pair)
            self.key = nil
        } else {
            key = value
        }
    }

    func encodeNil() throws {
        throw ProtobufEncodingError.nilValuesNotSupported
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            // Ensure that only same-type values are encoded
            if let first = content.first {
                if key == nil && first.key.dataType != primitive.dataType {
                    throw ProtobufEncodingError.multipleTypesInUnkeyedContainer
                }
                if key != nil && first.value.dataType != primitive.dataType {
                    throw ProtobufEncodingError.multipleTypesInUnkeyedContainer
                }
            }

            let node = try EncodedPrimitive(protobuf: primitive)
            assign(node)
            return
        }
        let node = try ProtoEncodingNode(path: codingPath, info: userInfo, optional: false).encoding(value)
        assign(node)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        // Should never happen, since this container type is only used for dictionaries
        fatalError()
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        // Should never happen, since this container type is only used for dictionaries
        fatalError()
    }

    func superEncoder() -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, path: codingPath, info: userInfo)
    }
}

extension ProtoDictUnkeyedEncoder: EncodingContainer {

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
        content.isEmpty
    }
}
