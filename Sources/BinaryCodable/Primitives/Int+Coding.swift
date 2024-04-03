import Foundation

extension Int: EncodablePrimitive {

    /// The integer encoded using zig-zag variable length encoding
    var encodedData: Data { zigZagEncoded }
}

extension Int: DecodablePrimitive {

    init(data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

// - MARK: Zig-zag encoding

extension Int: ZigZagEncodable {

    public var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }
}

extension Int: ZigZagDecodable {

    public init(fromZigZag data: Data) throws {
        let raw = try Int64(data: data)
        guard let value = Int(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "Int")
        }
        self = value
    }
}

extension ZigZagEncoded where WrappedValue == Int {
    
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

    public init(fromVarint data: Data) throws {
        let intValue = try Int64(fromVarint: data)
        guard let value = Int(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "Int")
        }
        self = value
    }
}

// - MARK: Fixed-size encoding

extension Int: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Int64(self).fixedSizeEncoded
    }
}

extension Int: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        let signed = try Int64(fromFixedSize: data)
        guard let value = Int(exactly: signed) else {
            throw CorruptedDataError(outOfRange: signed, forType: "Int")
        }
        self = value
    }
}

