import Foundation

extension UInt64: EncodablePrimitive {

    /// The value encoded using variable-length encoding
    var encodedData: Data { variableLengthEncoding }
}

extension UInt64: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromVarint: data)
    }
}

// - MARK: Variable-length encoding

extension UInt64: VariableLengthEncodable {

    /// The value encoded using variable-length encoding
    public var variableLengthEncoding: Data {
        var result = Data()
        var value = self
        // Iterate over the first 56 bit
        for _ in 0..<8 {
            // Extract 7 bit from value
            let nextByte = UInt8(value & 0x7F)
            value = value >> 7
            guard value > 0 else {
                result.append(nextByte)
                return result
            }
            // Set 8th bit to indicate another byte
            result.append(nextByte | 0x80)
        }
        // Add last byte if needed, no next byte indicator necessary
        if value > 0 {
            result.append(UInt8(value))
        }
        return result
    }
}

extension UInt64: VariableLengthDecodable {

    public init(fromVarint data: Data) throws {
        var currentIndex = data.startIndex
        
        func nextByte() throws -> UInt64 {
            guard currentIndex < data.endIndex else {
                throw CorruptedDataError(prematureEndofDataDecoding: "variable length integer")
            }
            defer { currentIndex += 1}
            return UInt64(data[currentIndex])
        }
        
        func ensureDataIsAtEnd() throws {
            guard currentIndex == data.endIndex else {
                throw CorruptedDataError(unusedBytes: data.endIndex - currentIndex, during: "variable length integer decoding")
            }
        }
        
        let startByte = try nextByte()
        guard startByte & 0x80 > 0 else {
            try ensureDataIsAtEnd()
            self = startByte
            return
        }

        var result = startByte & 0x7F
        // There are always 7 usable bits per byte, for 8 bytes
        for byteIndex in 1..<8 {
            let nextByte = try nextByte()
            // Insert the last 7 bit of the byte at the end
            result += UInt64(nextByte & 0x7F) << (byteIndex*7)
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                try ensureDataIsAtEnd()
                self = result
                return
            }
        }

        // The 9th byte has no next-byte bit, so all 8 bits are used
        let nextByte = try nextByte()
        result += UInt64(nextByte) << 56
        try ensureDataIsAtEnd()
        self = result
    }
}

extension VariableLengthEncoded where WrappedValue == UInt64 {
    
    @available(*, deprecated, message: "Property wrapper @VariableLengthEncoded has no effect on type UInt64")
    public init(wrappedValue: UInt64) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Fixed-size encoding

extension UInt64: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt64: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt64")
        }
        self.init(littleEndian: data.interpreted())
    }
}
