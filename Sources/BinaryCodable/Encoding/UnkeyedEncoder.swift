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
        nilIndices.insert(count)
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            try assign {
                try EncodedPrimitive(primitive: primitive)
            }
            return
        }
        let node = try EncodingNode(path: codingPath, info: userInfo).encoding(value)
        if node.isNil {
            try encodeNil()
        } else {
            assign { node }
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign {
            KeyedEncoder<NestedKey>(path: codingPath, info: userInfo)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assign {
            UnkeyedEncoder(path: codingPath, info: userInfo)
        }
    }
    
    func superEncoder() -> Encoder {
        assign {
            EncodingNode(path: codingPath, info: userInfo)
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

    var data: Data {
        nilIndicesData + contentData
    }
    
    var dataType: DataType {
        .variableLength
    }

    var isEmpty: Bool {
        count == 0
    }
}
