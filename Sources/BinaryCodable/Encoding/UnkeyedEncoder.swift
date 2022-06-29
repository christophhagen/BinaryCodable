import Foundation

final class UnkeyedEncoder: AbstractEncodingNode, UnkeyedEncodingContainer {
    
    var count: Int {
        content.count + nilIndices.count
    }
    
    private var content = [EncodingContainer]()
    
    private var nilIndices = Set<Int>()
    
    @discardableResult
    private func assign<T>(_ encoded: () throws -> T) rethrows -> T where T: EncodingContainer {
        let value = try encoded()
        content.append(value)
        return value
    }
    
    func encodeNil() throws {
        guard !forceProtobufCompatibility else {
            throw BinaryEncodingError.notProtobufCompatible
        }
        nilIndices.insert(count)
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            // Ensure that only same-type values are encoded
            if forceProtobufCompatibility {
                if let first = content.first, first.dataType != primitive.dataType {
                    throw BinaryEncodingError.notProtobufCompatible
                }
            }
            try assign {
                try EncodedPrimitive(primitive: primitive, protobuf: forceProtobufCompatibility)
            }
            return
        }
        let node = try EncodingNode(codingPath: codingPath, options: options).encoding(value)
        if node.isNil {
            try encodeNil()
        } else {
            assign { node }
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign {
            KeyedEncoder<NestedKey>(codingPath: codingPath, options: options)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assign {
            UnkeyedEncoder(codingPath: codingPath, options: options)
        }
    }
    
    func superEncoder() -> Encoder {
        assign {
            EncodingNode(codingPath: codingPath, options: options)
        }
    }
}

extension UnkeyedEncoder: EncodingContainer {

    private var rawIndicesData: Data {
        nilIndices.sorted().map { $0.variableLengthEncoding }.joinedData
    }
    
    private var nilIndicesData: Data {
        let count = nilIndices.count
        return count.variableLengthEncoding + rawIndicesData
    }
    
    private var contentData: Data {
        content.map { $0.dataWithLengthInformationIfRequired }.joinedData
    }

    private var packedProtoData: Data {
        let data = contentData
        return data.count.variableLengthEncoding + data
    }

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        guard forceProtobufCompatibility else {
            return key.encode(for: dataType) + dataWithLengthInformationIfRequired
        }
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
        nilIndicesData + contentData
    }
    
    var dataType: DataType {
        .variableLength
    }
}
