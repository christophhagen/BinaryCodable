import Foundation

extension Int: EncodablePrimitive {

    /// The integer encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        try self.init(fromZigZag: data, codingPath: codingPath)
    }
}

extension Int: ZigZagEncodable {

    var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int: ZigZagDecodable {

    init(fromZigZag data: Data, codingPath: [any CodingKey]) throws {
        let raw = try Int64(data: data, codingPath: codingPath)
        guard let value = Int(exactly: raw) else {
            throw DecodingError.corrupted("Decoded value \(raw) is out of range for type Int", codingPath: codingPath)
        }
        self = value
    }
}


extension Int: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    var variableLengthEncoding: Data {
        Int64(self).variableLengthEncoding
    }
}

extension Int: VariableLengthDecodable {

    init(fromVarint data: Data, codingPath: [CodingKey]) throws {
        let intValue = try Int64(fromVarint: data, codingPath: codingPath)
        guard let value = Int(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(codingPath)
        }
        self = value
    }
}

