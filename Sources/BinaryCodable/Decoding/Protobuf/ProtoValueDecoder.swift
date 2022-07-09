import Foundation

final class ProtoValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: DataDecoder

    private let isAtTopLevel: Bool

    init(data: DataDecoder, top: Bool = false, path: [CodingKey], info: UserInfo) {
        self.data = data
        self.isAtTopLevel = top
        super.init(path: path, info: info)
    }

    func decodeNil() -> Bool {
        false
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        guard let Primitive = type as? DecodablePrimitive.Type else {
            let node = ProtoDecodingNode(decoder: data, path: codingPath, info: userInfo)
            return try T.init(from: node)
        }

        guard let ProtoType = Primitive as? ProtobufDecodable.Type else {
            throw ProtobufDecodingError.unsupported(type: type)
        }
        guard self.data.hasMoreBytes else {
            return ProtoType.zero as! T
        }
        let data = try self.data.getData(for: Primitive.dataType)
        return try ProtoType.init(fromProtobuf: data) as! T
    }
}
