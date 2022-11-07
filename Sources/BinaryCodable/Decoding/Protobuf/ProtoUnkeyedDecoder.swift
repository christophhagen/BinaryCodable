import Foundation

final class ProtoUnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    private let decoder: BinaryStreamProvider

    init(data: Data, path: [CodingKey], info: UserInfo) throws {
        self.decoder = DataDecoder(data: data)
        super.init(path: path, info: info)
    }

    var count: Int? {
        nil
    }

    var isAtEnd: Bool {
        !decoder.hasMoreBytes
    }

    var currentIndex: Int = 0

    func decodeNil() -> Bool {
        return false
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer { currentIndex += 1 }
        if let Primitive = type as? DecodablePrimitive.Type {
            let dataType = Primitive.dataType
            let data = try decoder.getData(for: dataType)
            if let ProtoType = type as? ProtobufDecodable.Type {
                return try ProtoType.init(fromProtobuf: data) as! T
            }
            throw ProtobufDecodingError.unsupported(type: type)
        }
        let node = ProtoDecodingNode(decoder: decoder, path: codingPath, info: userInfo)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        currentIndex += 1
        let data = try decoder.getData(for: .variableLength)
        let container = try ProtoKeyedDecoder<NestedKey>(data: data, path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        currentIndex += 1
        let data = try decoder.getData(for: .variableLength)
        return try ProtoUnkeyedDecoder(data: data, path: codingPath, info: userInfo)
    }

    func superDecoder() throws -> Decoder {
        currentIndex += 1
        return ProtoDecodingNode(decoder: decoder, path: codingPath, info: userInfo)
    }
}
