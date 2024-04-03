import Foundation

extension Int: EncodablePrimitive {

    /// The integer encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

extension Int: ZigZagEncodable {

    var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int: ZigZagDecodable {

    init(fromZigZag data: Data) throws {
        let raw = try Int64(data: data)
        guard let value = Int(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int")
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

    init(fromVarint data: Data) throws {
        let intValue = try Int64(fromVarint: data)
        guard let value = Int(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "Int")
        }
        self = value
    }
}

