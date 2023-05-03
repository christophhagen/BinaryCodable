import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: BinaryStreamProvider

    private let isOptional: Bool

    init(data: BinaryStreamProvider, isOptional: Bool, path: [CodingKey], info: UserInfo) {
        self.data = data
        self.isOptional = isOptional
        super.init(path: path, info: info)
    }

    func decodeNil() -> Bool {
        do {
            let byte = try data.getByte(path: codingPath)
            return byte == 0
        } catch {
            return false
        }
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if type is AnyOptional.Type {
            let node = DecodingNode(decoder: data, isOptional: true, path: codingPath, info: userInfo)
            return try T.init(from: node)
        } else if let Primitive = type as? DecodablePrimitive.Type {
            let data: Data
            if Primitive.dataType == .variableLength, !isOptional, let d = self.data as? DataDecoder {
                data = d.getAllData()
            } else {
                data = try self.data.getData(for: Primitive.dataType, path: codingPath)
            }
            return try Primitive.init(decodeFrom: data, path: codingPath) as! T
        } else {
            let node = DecodingNode(decoder: data, path: codingPath, info: userInfo)
            return try T.init(from: node)
        }
    }
}
