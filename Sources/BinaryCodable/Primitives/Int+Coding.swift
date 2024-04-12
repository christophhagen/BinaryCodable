import Foundation

extension Int: EncodablePrimitive {

    /// The integer encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int: DecodablePrimitive {

    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    public init(data: Data) throws {
        let raw = try UInt64(fromVarintData: data)
        try self.init(fromZigZag: raw)
    }
}

// - MARK: Zig-zag encoding

extension Int: ZigZagEncodable {

    /// The integer encoded using zig-zag encoding
    public var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int: ZigZagDecodable {

    /**
     Decode an integer from zig-zag encoded data.
     - Parameter data: The data of the zig-zag encoded value.
     - Throws: ``CorruptedDataError``
     */
    public init(fromZigZag raw: UInt64) throws {
        let raw = Int64(fromZigZag: raw)
        guard let value = Int(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int")
        }
        self = value
    }
}

extension ZigZagEncoded where WrappedValue == Int {
    
    /**
     Wrap an integer to enforce zig-zag encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `Int` is already encoded using zig-zag encoding, so wrapping it in `ZigZagEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @ZigZagEncoded has no effect on type Int")
    public init(wrappedValue: Int) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Variable-length encoding

extension Int: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    public var variableLengthEncoding: Data {
        Int64(self).variableLengthEncoding
    }
}

extension Int: VariableLengthDecodable {

    /**
     Create an integer from variable-length encoded data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromVarint raw: UInt64) throws {
        let intValue = Int64(fromVarint: raw)
        guard let value = Int(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "Int")
        }
        self = value
    }
}

// - MARK: Fixed-size encoding

extension Int: FixedSizeEncodable {

    /// The value encoded as fixed-size data
    public var fixedSizeEncoded: Data {
        Int64(self).fixedSizeEncoded
    }
}

extension Int: FixedSizeDecodable {

    /**
     Decode a value from fixed-size data.
     - Parameter data: The data to decode.
     - Throws: ``CorruptedDataError``
     */
    public init(fromFixedSize data: Data) throws {
        let signed = try Int64(fromFixedSize: data)
        guard let value = Int(exactly: signed) else {
            throw CorruptedDataError(outOfRange: signed, forType: "Int")
        }
        self = value
    }
}

// - MARK: Packed

extension Int: PackedEncodable {

}

extension Int: PackedDecodable {

    public init(data: Data, index: inout Int) throws {
        guard let raw = data.decodeUInt64(at: &index) else {
            throw CorruptedDataError(prematureEndofDataDecoding: "Int")
        }
        try self.init(fromZigZag: raw)
    }
}
