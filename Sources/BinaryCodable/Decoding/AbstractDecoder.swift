import Foundation

protocol AbstractDecoder {
    
    var parentDecodedNil: Bool { get }
    
    var userInfo: UserInfo { get }
}

extension AbstractDecoder {
    
    func decode<T>(element: Data?, type: T.Type, codingPath: [CodingKey]) throws -> T where T: Decodable {
        if let BaseType = T.self as? DecodablePrimitive.Type {
            guard let element else {
                throw DecodingError.valueNotFound(type, codingPath: codingPath, "Found nil instead of expected type \(type)")
            }
            return try wrapCorruptDataError(at: codingPath) {
                try BaseType.init(data: element) as! T
            }
        }
        let node = try DecodingNode(data: element, parentDecodedNil: parentDecodedNil, codingPath: codingPath, userInfo: userInfo)
        return try type.init(from: node)
    }
}
