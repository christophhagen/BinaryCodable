import Foundation

extension UInt64: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt64: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt64")
        }
        self.init(littleEndian: data.interpreted())
    }
}
