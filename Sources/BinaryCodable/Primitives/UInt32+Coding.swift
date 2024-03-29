import Foundation

extension UInt32: EncodablePrimitive {

    /// The value encoded using variable-length encoding
    var encodedData: Data { variableLengthEncoding }
}

extension UInt32: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        try self.init(fromVarint: data, codingPath: codingPath)
    }
}

extension UInt32: VariableLengthEncodable {

    /// The value encoded using variable-length encoding
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }

}

extension UInt32: VariableLengthDecodable {

    init(fromVarint data: Data, codingPath: [any CodingKey]) throws {
        let raw = try UInt64(fromVarint: data, codingPath: codingPath)
        guard let value = UInt32(exactly: raw) else {
            throw DecodingError.corrupted("Decoded value \(raw) is out of range for type UInt32", codingPath: codingPath)
        }
        self = value
    }
}
