import Foundation

final class UnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    private let decoder: DataDecoder

    private let nilIndices: Set<Int>

    init(data: Data, codingPath: [CodingKey], options: Set<CodingOption>) throws {
        let decoder = DataDecoder(data: data)
        self.decoder = decoder
        let nilIndicesCount = try decoder.getVarint()
        self.nilIndices = try (0..<nilIndicesCount)
            .map { _ in try decoder.getVarint() }
            .reduce(into: []) { $0.insert($1) }

        super.init(codingPath: codingPath, options: options)
    }

    var count: Int? {
        nil
    }

    var isAtEnd: Bool {
        !nextValueIsNil && !decoder.hasMoreBytes
    }

    var currentIndex: Int = 0

    private var nextValueIsNil: Bool {
        nilIndices.contains(currentIndex)
    }

    func decodeNil() throws -> Bool {
        guard nilIndices.contains(currentIndex) else {
            return false
        }
        currentIndex += 1
        return true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer { currentIndex += 1 }
        if let Primitive = type as? DecodablePrimitive.Type {
            let dataType = Primitive.dataType
            let data = try decoder.getData(for: dataType)
            return try Primitive.init(decodeFrom: data) as! T
        }
        if let Opt = type as? AnyOptional.Type {
            if nextValueIsNil {
                return Opt.nilValue as! T
            } else {
                let node = DecodingNode(decoder: decoder, codingPath: codingPath, options: options)
                return try T.init(from: node)
            }
        }
        let node = DecodingNode(decoder: decoder, codingPath: codingPath, options: options)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        currentIndex += 1
        let data = try decoder.getData(for: .variableLength)
        let container = try KeyedDecoder<NestedKey>(data: data, codingPath: codingPath, options: options)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        currentIndex += 1
        let data = try decoder.getData(for: .variableLength)
        return try UnkeyedDecoder(data: data, codingPath: codingPath, options: options)
    }

    func superDecoder() throws -> Decoder {
        currentIndex += 1
        return DecodingNode(decoder: decoder, codingPath: codingPath, options: options)
    }
}
