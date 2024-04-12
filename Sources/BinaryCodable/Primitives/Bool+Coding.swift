import Foundation

extension Bool: EncodablePrimitive {

    /// The boolean encoded as data
    var encodedData: Data {
        Data([self ? 1 : 0])
    }
}

extension Bool: DecodablePrimitive {

    private init(byte: UInt8) throws {
        switch byte {
        case 0:
            self = false
        case 1:
            self = true
        default:
            throw CorruptedDataError(invalidBoolByte: byte)
        }
    }

    /**
     Decode a boolean from encoded data.
     - Parameter data: The data to decode
     - Throws: ``CorruptedDataError``
     */
    public init(data: Data) throws {
        guard data.count == 1 else {
            throw CorruptedDataError(invalidSize: data.count, for: "Bool")
        }
        try self.init(byte: data[data.startIndex])
    }
}

// - MARK: Fixed size

extension Bool: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        encodedData
    }
}

extension Bool: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        try self.init(data: data)
    }
}

extension FixedSizeEncoded where WrappedValue == Bool {

    /**
     Wrap a Bool to enforce fixed-size encoding.
     - Parameter wrappedValue: The value to wrap
     - Note: `Bool` is already encoded using fixed-size encoding, so wrapping it in `FixedSizeEncoded` does nothing.
     */
    @available(*, deprecated, message: "Property wrapper @FixedSizeEncoded has no effect on type Bool")
    public init(wrappedValue: Bool) {
        self.wrappedValue = wrappedValue
    }
}

// - MARK: Packed

extension Bool: PackedEncodable {

}

extension Bool: PackedDecodable {
    
    public init(data: Data, index: inout Int) throws {
        guard let bytes = data.nextBytes(Self.fixedEncodedByteCount, at: &index) else {
            throw CorruptedDataError.init(prematureEndofDataDecoding: "Bool")
        }
        try self.init(fromFixedSize: bytes)
    }
}
