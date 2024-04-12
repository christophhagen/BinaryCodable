import Foundation

extension Float: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: bitPattern.bigEndian)
    }
}

extension Float: DecodablePrimitive {

    public init(data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Float")
        }
        let value = UInt32(bigEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

// - MARK: Fixed size

extension Float: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        encodedData
    }
}

extension Float: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        try self.init(data: data)
    }
}

extension FixedSizeEncoded where WrappedValue == Float {

    /**
     Wrap a float to enforce fixed-size encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `Float` is already encoded using fixed-size encoding, so wrapping it in `FixedSizeEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type Float")
    public init(wrappedValue: Float) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Packed

extension Float: PackedEncodable {

}

extension Float: PackedDecodable {

    public init(data: Data, index: inout Int) throws {
        guard let bytes = data.nextBytes(Self.fixedEncodedByteCount, at: &index) else {
            throw CorruptedDataError.init(prematureEndofDataDecoding: "Float")
        }
        try self.init(data: bytes)
    }
}
