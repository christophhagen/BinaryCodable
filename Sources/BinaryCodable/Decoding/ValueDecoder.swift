import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: DataDecoder

    private let isAtTopLevel: Bool

    private let isNil: Bool

    init(data: DataDecoder, isNil: Bool, top: Bool = false, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.data = data
        self.isNil = isNil
        self.isAtTopLevel = top
        super.init(codingPath: codingPath, options: options)
    }

    func decodeNil() -> Bool {
        isNil || !data.hasMoreBytes
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
        let node = DecodingNode(decoder: data, codingPath: codingPath, options: options)
        return try T.init(from: node)
    }
}
