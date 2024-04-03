import Foundation

extension UInt16: EncodablePrimitive {

    var encodedData: Data { fixedSizeEncoded }
}

extension UInt16: DecodablePrimitive {

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
    
    public var fixedSizeEncoded: Data {
        .init(underlying: littleEndian)
    }
}

extension UInt16: FixedSizeDecodable {
    
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt16")
        }
        self.init(littleEndian: data.interpreted())
    }
}

extension FixedSizeEncoded where WrappedValue == UInt16 {
    
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type UInt16")
    public init(wrappedValue: UInt16) {
        self.wrappedValue = wrappedValue
    }
}

