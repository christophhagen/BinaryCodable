import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: BinaryStreamProvider

    private let isOptional: Bool

    init(data: BinaryStreamProvider, isOptional: Bool, path: [CodingKey], info: UserInfo) {
        print("ValueDecoder.init(optional: \(isOptional))")
        self.data = data
        self.isOptional = isOptional
        super.init(path: path, info: info)
    }

    func decodeNil() -> Bool {
        do {
            let byte = try data.getByte()
            print("ValueDecoder.decodeNil(\(byte == 0))")
            return byte == 0
        } catch {
            return false
        }
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if type is AnyOptional.Type {
            print("ValueDecoder.decode optional")
            let node = DecodingNode(decoder: data, isOptional: true, path: codingPath, info: userInfo)
            return try T.init(from: node)
        } else if let Primitive = type as? DecodablePrimitive.Type {
            let data: Data
            if Primitive.dataType == .variableLength, !isOptional, let d = self.data as? DataDecoder {
                print("ValueDecoder.decode primitive (all)")
                data = d.getAllData()
            } else {
                print("ValueDecoder.decode primitive")
                data = try self.data.getData(for: Primitive.dataType)
            }
            return try Primitive.init(decodeFrom: data) as! T
        } else {
            let node = DecodingNode(decoder: data, path: codingPath, info: userInfo)
            return try T.init(from: node)
        }
    }
}
