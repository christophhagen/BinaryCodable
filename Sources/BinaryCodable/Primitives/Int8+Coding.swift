import Foundation

extension Int8: EncodablePrimitive {

    var encodedData: Data {
        Data([UInt8(bitPattern: self)])
    }
}

extension Int8: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == 1 else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int8")
        }
        self.init(bitPattern: data[data.startIndex])
    }
}

// - MARK: Fixed size

extension Int8: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        encodedData
    }
}

extension Int8: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        try self.init(data: data)
    }
}

extension FixedSizeEncoded where WrappedValue == Int8 {

    /**
     Wrap a Int8 to enforce fixed-size encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `Int8` is already encoded using fixed-size encoding, so wrapping it in `FixedSizeEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type Int8")
    public init(wrappedValue: Int8) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Packed

extension Int8: PackedEncodable {

}

extension Int8: PackedDecodable {

    init(data: Data, index: inout Int) throws {
        guard let bytes = data.nextBytes(Self.fixedEncodedByteCount, at: &index) else {
            throw CorruptedDataError.init(prematureEndofDataDecoding: "Int8")
        }
        try self.init(fromFixedSize: bytes)
    }
}
