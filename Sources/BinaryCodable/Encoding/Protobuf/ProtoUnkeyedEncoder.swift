import Foundation

final class ProtoUnkeyedEncoder: AbstractEncodingNode, UnkeyedEncodingContainer {

    var count: Int {
        content.count
    }

    private var content = [NonNilEncodingContainer]()

    @discardableResult
    private func assign<T>(_ encoded: () throws -> T) rethrows -> T where T: NonNilEncodingContainer {
        let value = try encoded()
        content.append(value)
        return value
    }

    func encodeNil() throws {
        throw BinaryEncodingError.nilValuesNotSupported
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            // Ensure that only same-type values are encoded

            #warning("Improve detection of same types")
            if let first = content.first, first.dataType != primitive.dataType {
                throw BinaryEncodingError.notProtobufCompatible("All values in unkeyed containers must have the same type")
            }

            try assign {
                try EncodedPrimitive(protobuf: primitive)
            }
            return
        }
        let node = try ProtoEncodingNode(codingPath: codingPath, options: options).encoding(value)
        assign { node }
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign {
            ProtoKeyedEncoder<NestedKey>(codingPath: codingPath, options: options)
        }
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assign {
            ProtoUnkeyedEncoder(codingPath: codingPath, options: options)
        }
    }

    func superEncoder() -> Encoder {
        assign {
            ProtoEncodingNode(codingPath: codingPath, options: options)
        }
    }
}

extension ProtoUnkeyedEncoder: NonNilEncodingContainer {

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
