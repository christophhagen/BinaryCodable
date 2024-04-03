import Foundation

extension UInt: EncodablePrimitive {

    var encodedData: Data { variableLengthEncoding }
}

extension UInt: DecodablePrimitive {

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

    public init(fromVarint data: Data) throws {
        let raw = try UInt64(fromVarint: data)
        guard let value = UInt(exactly: raw) else {
            throw CorruptedDataError(outOfRange: raw, forType: "UInt")
        }
        self = value
    }
}

extension VariableLengthEncoded where WrappedValue == UInt {
    
    @available(*, deprecated, message: "Property wrapper @VariableLengthEncoded has no effect on type UInt")
    public init(wrappedValue: UInt) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Fixed-size encoding

extension UInt: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
    }
}

extension UInt: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        let intValue = try UInt64(fromFixedSize: data)
        guard let value = UInt(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "UInt")
        }
        self = value
    }
}

