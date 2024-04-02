import Foundation

extension String: EncodablePrimitive {

    var encodedData: Data {
        data(using: .utf8)!
    }
}

extension String: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard let value = String(data: data, encoding: .utf8) else {
            throw DecodingError.corrupted("Invalid string", codingPath: codingPath)
        }
        self = value
    }
}
