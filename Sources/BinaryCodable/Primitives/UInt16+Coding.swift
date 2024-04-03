import Foundation

extension UInt16: EncodablePrimitive {

    /// The value encoded as fixed-size data
    var encodedData: Data { fixedSizeEncoded }
}

extension UInt16: DecodablePrimitive {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    init(data: Data) throws {
        try self.init(fromFixedSize: data)
    }
}

// - MARK: Variable-length encoding

extension UInt16: VariableLengthEncodable {
    
    public var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
}

extension UInt16: VariableLengthDecodable {
    
    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
        guard let value = UInt16(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt16")
        }
        self = value
    }
}

// - MARK: Fixed-size encoding

extension UInt16: FixedSizeEncodable {
    
    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        .init(underlying: littleEndian)
    }
}

extension UInt16: FixedSizeDecodable {
    
    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt16")
        }
        self.init(littleEndian: data.interpreted())
    }
}

extension FixedSizeEncoded where WrappedValue == UInt16 {
    
    /**
     Wrap an integer to enforce fixed-size encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `UInt16` is already encoded using fixed-size encoding, so wrapping it in `FixedSizeEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type UInt16")
    public init(wrappedValue: UInt16) {
        self.wrappedValue = wrappedValue
    }
}

