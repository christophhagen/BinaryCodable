import Foundation

extension UInt: EncodablePrimitive {

    var encodedData: Data { variableLengthEncoding }
}

extension UInt: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        try self.init(fromVarint: data, codingPath: codingPath)

    }
}

extension UInt: VariableLengthCodable {

    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }

    init(fromVarint data: Data, codingPath: [any CodingKey]) throws {
        let raw = try UInt64(fromVarint: data, codingPath: codingPath)
        guard let value = UInt(exactly: raw) else {
            throw DecodingError.corrupted("Decoded value \(raw) is out of range for type UInt", codingPath: codingPath)
        }
        self = value
    }
}
