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
    init(data: Data) throws {
        try self.init(fromVarint: data)
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
    public init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
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

