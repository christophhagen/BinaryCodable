import Foundation

extension Int16: EncodablePrimitive {

    var encodedData: Data { fixedSizeEncoded }
}

extension Int16: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromFixedSize: data)
    }
}

// - MARK: Fixed size

extension Int16: FixedSizeEncodable {
    
    public var fixedSizeEncoded: Data {
        .init(underlying: UInt16(bitPattern: self).littleEndian)
    }
}

extension Int16: FixedSizeDecodable {
    
    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int16")
        }
        let value = UInt16(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

extension FixedSizeEncoded where WrappedValue == Int16 {
    
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
    
    public init(fromVarint data: Data) throws {
        let value = try UInt16(fromVarint: data)
        self = Int16(bitPattern: value)
    }
}

// - MARK: Zig-zag encoding

extension Int16: ZigZagEncodable {

    public var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int16: ZigZagDecodable {

    public init(fromZigZag data: Data) throws {
        let raw = try Int64(fromZigZag: data)
        guard let value = Int16(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int16")
        }
        self = value
    }
}
