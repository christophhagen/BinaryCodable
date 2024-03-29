import Foundation

extension UInt64: EncodablePrimitive {

    /// The value encoded using variable-length encoding
    var encodedData: Data { variableLengthEncoding }
}

extension UInt64: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        try self.init(fromVarint: data, codingPath: codingPath)
    }
}

extension UInt64: VariableLengthEncodable {

    /// The value encoded using variable-length encoding
    var variableLengthEncoding: Data {
        var result = Data()
        var value = self
        // Iterate over the first 56 bit
        for _ in 0..<8 {
            // Extract 7 bit from value
            let nextByte = UInt8(value & 0x7F)
            value = value >> 7
            guard value > 0 else {
                result.append(nextByte)
                return result
            }
            // Set 8th bit to indicate another byte
            result.append(nextByte | 0x80)
        }
        // Add last byte if needed, no next byte indicator necessary
        if value > 0 {
            result.append(UInt8(value))
        }
        return result
    }
}

extension UInt64: VariableLengthDecodable {

    init(fromVarint data: Data, codingPath: [any CodingKey]) throws {
        let storage = DecodingStorage(data: data, codingPath: codingPath)
        let value = try storage.decodeUInt64()
        guard storage.isAtEnd else {
            throw DecodingError.corrupted("\(storage.numberOfRemainingBytes) unused bytes left after decoding variable length integer", codingPath: codingPath)
        }
        self = value
    }
}
