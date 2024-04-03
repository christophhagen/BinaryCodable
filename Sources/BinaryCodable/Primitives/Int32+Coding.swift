import Foundation

extension Int32: EncodablePrimitive {

    /// The integer encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int32: DecodablePrimitive {

    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    init(data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

// - MARK: Zig-zag encoding

extension Int32: ZigZagEncodable {

    /// The integer encoded using zig-zag encoding
    public var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int32: ZigZagDecodable {

    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    public init(fromZigZag data: Data) throws {
        let raw = try Int64(fromZigZag: data)
        guard let value = Int32(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int32")
        }
        self = value
    }
}

extension ZigZagEncoded where WrappedValue == Int32 {
    
    /**
     Wrap an integer to enforce zig-zag encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `Int32` is already encoded using zig-zag encoding, so wrapping it in `ZigZagEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @ZigZagEncoded has no effect on type Int32")
    public init(wrappedValue: Int32) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Variable-length encoding

extension Int32: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    public var variableLengthEncoding: Data {
        UInt32(bitPattern: self).variableLengthEncoding
    }
}

extension Int32: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint data: Data) throws {
        let value = try UInt32(fromVarint: data)
        self = Int32(bitPattern: value)
    }
}

// - MARK: Fixed-size encoding

extension Int32: FixedSizeEncodable {

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        let value = UInt32(bitPattern: littleEndian)
        return Data(underlying: value)
    }
}

extension Int32: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int32")
        }
        let value = UInt32(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
