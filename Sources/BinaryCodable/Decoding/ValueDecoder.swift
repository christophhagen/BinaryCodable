import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: BinaryStreamProvider

    private let isAtTopLevel: Bool

    private let isNil: Bool

    init(data: BinaryStreamProvider, isNil: Bool, top: Bool = false, path: [CodingKey], info: UserInfo) {
        self.data = data
        self.isNil = isNil
        self.isAtTopLevel = top
        super.init(path: path, info: info)
    }

    func decodeNil() -> Bool {
        isNil || !data.hasMoreBytes
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let Primitive = type as? DecodablePrimitive.Type {
            let data: Data
            if Primitive.dataType == .variableLength, isAtTopLevel, let d = self.data as? DataDecoder {
                data = d.getAllData()
            } else {
                data = try self.data.getData(for: Primitive.dataType)
            }
            return try Primitive.init(decodeFrom: data) as! T
        }
        let node = DecodingNode(decoder: data, path: codingPath, info: userInfo)
        return try T.init(from: node)
    }
}
