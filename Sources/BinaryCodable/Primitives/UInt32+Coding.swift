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

// - MARK: Variable-length encoding

extension UInt32: VariableLengthEncodable {

    /// The value encoded using variable-length encoding
    public var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }

}

extension UInt32: VariableLengthDecodable {

    public init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
        guard let value = UInt32(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt32")
        }
        self = value
    }
}

extension VariableLengthEncoded where WrappedValue == UInt32 {
    
    @available(*, deprecated, message: "Property wrapper @VariableLengthEncoded has no effect on type UInt32")
    public init(wrappedValue: UInt32) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Fixed-size encoding

extension UInt32: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt32: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt32")
        }
        self.init(littleEndian: data.interpreted())
    }
}
