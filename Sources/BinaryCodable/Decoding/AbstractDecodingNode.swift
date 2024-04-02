import Foundation

/**
 A class to provide decoding functions to all decoding containers.
 */
class AbstractDecodingNode: AbstractNode {

    let parentDecodedNil: Bool

    init(parentDecodedNil: Bool, codingPath: [CodingKey], userInfo: UserInfo) {
        self.parentDecodedNil = parentDecodedNil
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    func decode<T>(element: Data?, type: T.Type, codingPath: [CodingKey]) throws -> T where T: Decodable {
        if let BaseType = T.self as? DecodablePrimitive.Type {
            guard let element else {
                throw DecodingError.valueNotFound(type, codingPath: codingPath, "Found nil instead of expected type \(type)")
            }
            return try BaseType.init(data: element, codingPath: codingPath) as! T
        }
        let node = try DecodingNode(data: element, parentDecodedNil: parentDecodedNil, codingPath: codingPath, userInfo: userInfo)
        return try type.init(from: node)
    }
}
