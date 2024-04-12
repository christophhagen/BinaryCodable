import Foundation

extension Double: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: bitPattern.bigEndian)
    }
}

extension Double: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Double")
        }
        let value = UInt64(bigEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

// - MARK: Fixed size

extension Double: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        encodedData
    }
}

extension Double: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        try self.init(data: data)
    }
}

extension FixedSizeEncoded where WrappedValue == Double {

    /**
     Wrap a double to enforce fixed-size encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `Double` is already encoded using fixed-size encoding, so wrapping it in `FixedSizeEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type Double")
    public init(wrappedValue: Double) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Packed

extension Double: PackedEncodable {

}

extension Double: PackedDecodable {

    init(data: Data, index: inout Int) throws {
        guard let bytes = data.nextBytes(Self.fixedEncodedByteCount, at: &index) else {
            throw CorruptedDataError.init(prematureEndofDataDecoding: "Double")
        }
        try self.init(data: bytes)
    }
}
