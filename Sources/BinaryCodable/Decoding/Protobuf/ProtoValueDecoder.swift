import Foundation

final class ProtoValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: DataDecoder

    private let isAtTopLevel: Bool

    init(data: DataDecoder, top: Bool = false, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.data = data
        self.isAtTopLevel = top
        super.init(codingPath: codingPath, options: options)
    }

    func decodeNil() -> Bool {
        false
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard let Primitive = type as? DecodablePrimitive.Type else {
            let node = ProtoDecodingNode(decoder: data, codingPath: codingPath, options: options)
            return try T.init(from: node)
        }
        let data: Data
        if Primitive.dataType == .variableLength, isAtTopLevel {
            data = self.data.getAllData()
        } else {
            data = try self.data.getData(for: Primitive.dataType)
        }

        if let ProtoType = Primitive as? ProtobufDecodable.Type {
            return try ProtoType.init(fromProtobuf: data) as! T
        }
        throw BinaryDecodingError.unsupportedType(type)
    }
}
