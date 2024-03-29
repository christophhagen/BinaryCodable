import Foundation

extension String: EncodablePrimitive {
    
    static var dataType: DataType {
        .variableLength
    }
    
    func data() throws -> Data {
        guard let result = data(using: .utf8) else {
            throw EncodingError.invalidValue(self, .init(codingPath: [], debugDescription: "String is not UTF-8"))
        }
        return result
    }
}

extension String: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard let value = String(data: data, encoding: .utf8) else {
            let context = DecodingError.Context(codingPath: path, debugDescription: "Invalid string")
            throw DecodingError.dataCorrupted(context)
        }
        self = value
    }
}
