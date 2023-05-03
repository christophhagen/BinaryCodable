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

    init(decodeFrom data: Data) throws {
        guard let value = String(data: data, encoding: .utf8) else {
            throw BinaryDecodingError.invalidString
        }
        self = value
    }
}

extension String: ProtobufCodable {
    
    var protoType: String { "string" }

    static let zero = ""
}
