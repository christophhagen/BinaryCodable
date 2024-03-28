import Foundation

final class ProtoUnkeyedEncoder: AbstractEncodingNode, UnkeyedEncodingContainer {

    var count: Int {
        content.count
    }

    private var content = [EncodingContainer]()

    @discardableResult
    private func assign<T>(_ encoded: () throws -> T) rethrows -> T where T: EncodingContainer {
        let value = try encoded()
        content.append(value)
        return value
    }

    func encodeNil() throws {
        throw ProtobufEncodingError.nilValuesNotSupported
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            // Ensure that only same-type values are encoded

            // TODO: Improve detection of same types
            // The Protobuf repeated fields must have the same type
            // Currently, we only check that the data type of the primitives matches,
            // so different types with the same DataType would not cause an error
            // This isn't a huge problem, since this could only happen if somebody would
            // write a custom encoding routine, so they would probably know that this breaks
            // Protobuf support.
            if let first = content.first, first.dataType != primitive.dataType {
                throw ProtobufEncodingError.multipleTypesInUnkeyedContainer
            }

            try assign {
                try wrapError(path: codingPath) {
                    try EncodedPrimitive(protobuf: primitive)
                }
            }
            return
        }
        let node = try ProtoEncodingNode(path: codingPath, info: userInfo, optional: false).encoding(value)
        assign { node }
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign {
            ProtoKeyedEncoder<NestedKey>(path: codingPath, info: userInfo, optional: false)
        }
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assign {
            ProtoUnkeyedEncoder(path: codingPath, info: userInfo, optional: false)
        }
    }

    func superEncoder() -> Encoder {
        assign {
            ProtoEncodingNode(path: codingPath, info: userInfo, optional: false)
        }
    }
}

extension ProtoUnkeyedEncoder: EncodingContainer {

    private var packedProtoData: Data {
        let data = self.data
        return data.count.variableLengthEncoding + data
    }

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        // Don't prepend index set for protobuf, separate complex types
        if let first = content.first, first.dataType == .variableLength {
            // Unpacked
            return content
                .map { $0.encodeWithKey(key) }
                .joinedData
        }
        // Packed
        return key.encode(for: dataType) + packedProtoData
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
