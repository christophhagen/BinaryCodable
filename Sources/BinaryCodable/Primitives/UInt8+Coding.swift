import Foundation

extension UInt8: EncodablePrimitive {

    var encodedData: Data {
        Data([self])
    }
}

extension UInt8: DecodablePrimitive {

    public init(data: Data) throws {
        guard data.count == 1 else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt8")
        }
        self = data[data.startIndex]
    }
}

// - MARK: Fixed size

extension UInt8: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        encodedData
    }
}

extension UInt8: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        try self.init(data: data)
    }
}

extension FixedSizeEncoded where WrappedValue == UInt8 {

    /**
     Wrap a UInt8 to enforce fixed-size encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `UInt8` is already encoded using fixed-size encoding, so wrapping it in `FixedSizeEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type UInt8")
    public init(wrappedValue: UInt8) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Packed

extension UInt8: PackedEncodable {

}

extension UInt8: PackedDecodable {

    public init(data: Data, index: inout Int) throws {
        guard let bytes = data.nextBytes(Self.fixedEncodedByteCount, at: &index) else {
            throw CorruptedDataError.init(prematureEndofDataDecoding: "UInt8")
        }
        try self.init(fromFixedSize: bytes)
    }
}
