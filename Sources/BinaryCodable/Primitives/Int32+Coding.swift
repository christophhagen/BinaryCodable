import Foundation

extension Int32: EncodablePrimitive {

    /// The integer encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int32: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        try self.init(fromZigZag: data, codingPath: codingPath)
    }
}

extension Int32: ZigZagEncodable {

    var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int32: ZigZagDecodable {

    init(fromZigZag data: Data, codingPath: [any CodingKey]) throws {
        let raw = try Int64(data: data, codingPath: codingPath)
        guard let value = Int32(exactly: raw) else {
            throw DecodingError.corrupted("Decoded value \(raw) is out of range for type Int32", codingPath: codingPath)
        }
        self = value
    }
}

extension Int32: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    var variableLengthEncoding: Data {
        UInt32(bitPattern: self).variableLengthEncoding
    }
}

extension Int32: VariableLengthDecodable {

    init(fromVarint data: Data, codingPath: [CodingKey]) throws {
        let value = try UInt32(data: data, codingPath: codingPath)
        self = Int32(bitPattern: value)
    }
}
