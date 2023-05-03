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
        if value is AnyOptional {
            try assign {
                try EncodingNode(path: codingPath, info: userInfo, optional: true).encoding(value)
            }
        } else if let primitive = value as? EncodablePrimitive {
            try assign {
                try wrapError(path: codingPath) {
                    try EncodedPrimitive(primitive: primitive)
                }
            }
        } else {
            let node = try EncodingNode(path: codingPath, info: userInfo, optional: false).encoding(value)
            assign { node }
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign {
            KeyedEncoder<NestedKey>(path: codingPath, info: userInfo, optional: false)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assign {
            UnkeyedEncoder(path: codingPath, info: userInfo, optional: false)
        }
    }
    
    func superEncoder() -> Encoder {
        assign {
            EncodingNode(path: codingPath, info: userInfo, optional: false)
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
        if prependNilIndexSetForUnkeyedContainers {
            return nilIndicesData + contentData
        } else {
            return contentData
        }
    }
    
    var dataType: DataType {
        .variableLength
    }

    var isEmpty: Bool {
        count == 0
    }
}
