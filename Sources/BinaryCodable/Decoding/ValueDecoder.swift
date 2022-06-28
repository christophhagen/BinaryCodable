import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: DataDecoder

    private let isAtTopLevel: Bool

    init(data: DataDecoder, top: Bool = false, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        self.isAtTopLevel = top
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    func decodeNil() -> Bool {
        !data.hasMoreBytes
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let Primitive = type as? DecodablePrimitive.Type {
            let data: Data
            if Primitive.dataType == .variableLength, isAtTopLevel {
                data = self.data.getAllData()
            } else {
                data = try self.data.getData(for: Primitive.dataType)
            }
            return try Primitive.init(decodeFrom: data) as! T
        }
        let node = DecodingNode(decoder: data, codingPath: codingPath, userInfo: userInfo)
        return try T.init(from: node)
    }
}
