import Foundation

extension Int32: EncodablePrimitive {

    /// The integer encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int32: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

extension Int32: ZigZagEncodable {

    var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int32: ZigZagDecodable {

    init(fromZigZag data: Data) throws {
        let raw = try Int64(fromZigZag: data)
        guard let value = Int32(exactly: raw) else {
            throw CorruptedDataError("Decoded value \(raw) is out of range for type Int32")
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

    init(fromVarint data: Data) throws {
        let value = try UInt32(fromVarint: data)
        self = Int32(bitPattern: value)
    }
}
