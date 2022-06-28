import Foundation

extension String: EncodablePrimitive {
    
    static var dataType: DataType {
        .variableLength
    }
    
    func data() throws -> Data {
        guard let result = data(using: .utf8) else {
            throw BinaryEncodingError.stringEncodingFailed(self)
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

extension String {
    
    func indented(by indentation: String = "  ") -> String {
        components(separatedBy: "\n")
            .map { indentation + $0 }
            .joined(separator: "\n")
    }
}

extension String: ProtobufCodable {
    
}
