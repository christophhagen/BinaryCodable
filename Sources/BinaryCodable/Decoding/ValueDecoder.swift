import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    let data: Data

    init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    func decodeNil() -> Bool {
        data.isEmpty
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if let Primitive = type as? DecodablePrimitive.Type {
            return try Primitive.init(decodeFrom: data) as! T
        }
        let node = DecodingNode(data: data, codingPath: codingPath, userInfo: userInfo)
        return try T.init(from: node)
    }
}
