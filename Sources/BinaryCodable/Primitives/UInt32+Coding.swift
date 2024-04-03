import Foundation

extension UInt32: EncodablePrimitive {

    /// The value encoded using variable-length encoding
    var encodedData: Data { variableLengthEncoding }
}

extension UInt32: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromVarint: data)
    }
}

extension UInt32: VariableLengthEncodable {

    /// The value encoded using variable-length encoding
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }

}

extension UInt32: VariableLengthDecodable {

    init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
        guard let value = UInt32(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt32")
        }
        self = value
    }
}
