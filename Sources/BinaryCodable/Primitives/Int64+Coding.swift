import Foundation

extension Int64: EncodablePrimitive {

    /// The value encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int64: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

// - MARK: Zig-zag encoding

extension Int64: ZigZagEncodable {

    public var zigZagEncoded: Data {
        guard self < 0 else {
            return (UInt64(self.magnitude) << 1).variableLengthEncoding
        }
        return ((UInt64(-1 - self) << 1) + 1).variableLengthEncoding
    }
}

extension Int64: ZigZagDecodable {

    public init(fromZigZag data: Data) throws {
        let unsigned = try UInt64(fromVarint: data)

        // Check the last bit to get sign
        if unsigned & 1 > 0 {
            // Divide by 2 and subtract one to get absolute value of negative values.
            self = -Int64(unsigned >> 1) - 1
        } else {
            // Divide by two to get absolute value of positive values
            self = Int64(unsigned >> 1)
        }
    }
}

extension ZigZagEncoded where WrappedValue == Int64 {
    
    @available(*, deprecated, message: "Property wrapper @ZigZagEncoded has no effect on type Int64")
    public init(wrappedValue: Int64) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Variable-length encoding

extension Int64: VariableLengthEncodable {

    /// The value encoded using variable length encoding
    public var variableLengthEncoding: Data {
        UInt64(bitPattern: self).encodedData
    }

}

extension Int64: VariableLengthDecodable {

    public init(fromVarint data: Data) throws {
        let value = try UInt64(fromVarint: data)
        self = Int64(bitPattern: value)
    }
}

// - MARK: Fixed-size encoding

extension Int64: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        let value = UInt64(bitPattern: littleEndian)
        return Data.init(underlying: value)
    }
}

extension Int64: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int64")
        }
        let value = UInt64(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
