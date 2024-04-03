import Foundation

extension Int32: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        let value = UInt32(bitPattern: littleEndian)
        return Data(underlying: value)
    }
}

extension Int32: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int32")
        }
        let value = UInt32(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
