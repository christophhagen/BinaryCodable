import Foundation

extension UInt: EncodablePrimitive {

    var encodedData: Data { variableLengthEncoding }
}

extension UInt: DecodablePrimitive {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(data: Data) throws {
        let raw = try UInt64(fromVarintData: data)
        try self.init(fromVarint: raw)
    }
}

// - MARK: Variable-length encoding

extension UInt: VariableLengthEncodable {
    
    public var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
}

extension UInt: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint raw: UInt64) throws {
        guard let value = UInt(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt")
        }
        self = value
    }
}

extension VariableLengthEncoded where WrappedValue == UInt {
    
    /**
     Wrap an integer to enforce variable-length encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `UInt` is already encoded using fixed-size encoding, so wrapping it in `VariableLengthEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @VariableLengthEncoded has no effect on type UInt")
    public init(wrappedValue: UInt) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Fixed-size encoding

extension UInt: FixedSizeEncodable {

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
    }
}

extension UInt: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        let intValue = try UInt64(fromFixedSize: data)
        guard let value = UInt(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "UInt")
        }
        self = value
    }
}

// - MARK: Packed

extension UInt: PackedEncodable {

}

extension UInt: PackedDecodable {

    public init(data: Data, index: inout Int) throws {
        guard let raw = data.decodeUInt64(at: &index) else {
            throw CorruptedDataError(prematureEndofDataDecoding: "UInt")
        }
        try self.init(fromVarint: raw)
    }
}
