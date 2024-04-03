import Foundation

extension UInt32: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt32: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt32")
        }
        self.init(littleEndian: data.interpreted())
    }
}
