import Foundation

extension Int16: EncodablePrimitive {

    var encodedData: Data { fixedSizeEncoded }
}

extension Int16: DecodablePrimitive {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(data: Data) throws {
        try self.init(fromFixedSize: data)
    }
}

// - MARK: Fixed size

extension Int16: FixedSizeEncodable {
    
    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        .init(underlying: UInt16(bitPattern: self).littleEndian)
    }
}

extension Int16: FixedSizeDecodable {
    
    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int16")
        }
        let value = UInt16(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

extension FixedSizeEncoded where WrappedValue == Int16 {
    
    /**
     Wrap an integer to enforce fixed-size encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `Int16` is already encoded using fixed-size encoding, so wrapping it in `FixedSizeEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type Int16")
    public init(wrappedValue: Int16) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Variable length

extension Int16: VariableLengthEncodable {
    
    public var variableLengthEncoding: Data {
        Int64(self).variableLengthEncoding
    }
}

extension Int16: VariableLengthDecodable {
    
    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint raw: UInt64) throws {
        let value = try UInt16(fromVarint: raw)
        self = Int16(bitPattern: value)
    }
}

// - MARK: Zig-zag encoding

extension Int16: ZigZagEncodable {

    /// The integer encoded using zig-zag encoding
    public var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int16: ZigZagDecodable {

    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    public init(fromZigZag raw: UInt64) throws {
        let raw = Int64(fromZigZag: raw)
        guard let value = Int16(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int16")
        }
        self = value
    }
}

// - MARK: Packed

extension Int16: PackedEncodable {

}

extension Int16: PackedDecodable {

    public init(data: Data, index: inout Int) throws {
        guard let bytes = data.nextBytes(Self.fixedEncodedByteCount, at: &index) else {
            throw CorruptedDataError.init(prematureEndofDataDecoding: "Int16")
        }
        try self.init(data: bytes)
    }
}
