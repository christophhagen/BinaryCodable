import Foundation

extension Int64: EncodablePrimitive {

    /// The value encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int64: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

extension Int64: ZigZagEncodable {

    var zigZagEncoded: Data {
        guard self < 0 else {
            return (UInt64(self.magnitude) << 1).variableLengthEncoding
        }
        return ((UInt64(-1 - self) << 1) + 1).variableLengthEncoding
    }
}

extension Int64: ZigZagDecodable {

    init(fromZigZag data: Data) throws {
        let unsigned = try UInt64(fromVarint: data)

        // Check the last bit to get sign
        if unsigned & 1 > 0 {
            // Divide by 2 and subtract one to get absolute value of negative values.
            self = -Int64(unsigned >> 1) - 1
        } else {
            // Divide by two to get absolute value of positive values
            self = Int64(unsigned >> 1)
        }
    }
}

extension Int64: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    var variableLengthEncoding: Data {
        UInt64(bitPattern: self).encodedData
    }

}

extension Int64: VariableLengthDecodable {

    init(fromVarint data: Data) throws {
        let value = try UInt64(fromVarint: data)
        self = Int64(bitPattern: value)
    }
}
