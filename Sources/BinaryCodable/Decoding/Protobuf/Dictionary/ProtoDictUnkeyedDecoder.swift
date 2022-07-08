import Foundation

final class ProtoDictUnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    let elements: [(dataType: DataType, data: Data)]

    init(data: Data, codingPath: [CodingKey], options: Set<CodingOption>) throws {
        let decoder = DataDecoder(data: data)
        var elements = [(dataType: DataType, data: Data)]()
        while decoder.hasMoreBytes {
            let pairData = try decoder.getData(for: .variableLength)
            let pairDecoder = DataDecoder(data: pairData)

            let (keyField, keyDataType) = try DecodingKey.decodeProto(from: pairDecoder)
            guard case .intKey(1) = keyField else {
                throw BinaryDecodingError.unexpectedDictionaryKey
            }
            let keyData = try pairDecoder.getData(for: keyDataType)
            elements.append((dataType: keyDataType, data: keyData))

            let (valueField, valueDataType) = try DecodingKey.decodeProto(from: pairDecoder)
            guard case .intKey(2) = valueField else {
                throw BinaryDecodingError.unexpectedDictionaryKey
            }
            let valueData = try pairDecoder.getData(for: valueDataType)
            elements.append((dataType: valueDataType, data: valueData))
        }
        self.elements = elements
        super.init(codingPath: codingPath, options: options)
    }

    var count: Int? {
        elements.count
    }

    var isAtEnd: Bool {
        currentIndex == elements.count
    }

    var currentIndex: Int = 0

    func decodeNil() -> Bool {
        return false
    }

    private var currentElement: (dataType: DataType, data: Data) {
        elements[currentIndex]
    }

    private func getCurrentElementVariableLengthData() throws -> Data {
        let element = currentElement
        guard element.dataType == .variableLength else {
            throw BinaryDecodingError.unexpectedDictionaryKey
        }
        return element.data
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer { currentIndex += 1 }
        if let Primitive = type as? DecodablePrimitive.Type {
            let element = currentElement
            guard element.dataType == Primitive.dataType else {
                throw BinaryDecodingError.unexpectedDictionaryKey
            }
            if let ProtoType = type as? ProtobufDecodable.Type {
                return try ProtoType.init(fromProtobuf: element.data) as! T
            }
            throw BinaryDecodingError.unsupportedType(type)
        }
        let decoder = DataDecoder(data: try getCurrentElementVariableLengthData())
        let node = ProtoDecodingNode(decoder: decoder, codingPath: codingPath, options: options)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        defer { currentIndex += 1 }
        let data = try getCurrentElementVariableLengthData()
        let container = try ProtoKeyedDecoder<NestedKey>(data: data, codingPath: codingPath, options: options)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        defer { currentIndex += 1 }
        let data = try getCurrentElementVariableLengthData()
        return try ProtoUnkeyedDecoder(data: data, codingPath: codingPath, options: options)
    }

    func superDecoder() throws -> Decoder {
        throw BinaryDecodingError.superNotSupported
    }
}