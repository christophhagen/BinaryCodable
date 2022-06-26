import Foundation

final class UnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    var data: DataDecoder

    let nilIndices: Set<Int>

    init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
        var decoder =  DataDecoder(data: data)
        self.data = decoder

        let nilIndicesCount = try decoder.getVarint()
        self.nilIndices = try (0..<nilIndicesCount)
            .map { _ in try decoder.getVarint() }
            .reduce(into: []) { $0.insert($1) }

        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    var count: Int? {
        nil
    }

    var isAtEnd: Bool {
        !nilIndices.contains(currentIndex) && !data.hasMoreBytes
    }

    var currentIndex: Int = 0

    func decodeNil() throws -> Bool {
        guard nilIndices.contains(currentIndex) else {
            return false
        }
        currentIndex += 1
        return true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let Primitive = type as? DecodablePrimitive.Type {
            let dataType = Primitive.dataType
            let data = try data.getData(for: dataType)
            return try Primitive.init(decodeFrom: data) as! T
        }
        // Decode length
        let data = try data.getData(for: .variableLength)
        let node = DecodingNode(data: data, codingPath: codingPath, userInfo: userInfo)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let data = try data.getData(for: .variableLength)
        let container = try KeyedDecoder<NestedKey>(data: data, codingPath: codingPath, userInfo: userInfo)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let data = try data.getData(for: .variableLength)
        return try UnkeyedDecoder(data: data, codingPath: codingPath, userInfo: userInfo)
    }

    func superDecoder() throws -> Decoder {
        let data = try data.getData(for: .variableLength)
        return DecodingNode(data: data, codingPath: codingPath, userInfo: userInfo)
    }
}
