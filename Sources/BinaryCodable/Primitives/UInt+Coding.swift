import Foundation

extension UInt: EncodablePrimitive {

    var encodedData: Data { variableLengthEncoding }
}

extension UInt: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromVarint: data)

    }
}

extension UInt: VariableLengthCodable {

    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }

    init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
        guard let value = UInt(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt")
        }
        self = value
    }
}
