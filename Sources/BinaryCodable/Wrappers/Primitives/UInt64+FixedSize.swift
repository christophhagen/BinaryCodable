import Foundation

extension UInt64: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt64: FixedSizeDecodable {

    public init(fromFixedSize data: Data, codingPath: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw DecodingError.invalidSize(size: data.count, for: "UInt64", codingPath: codingPath)
        }
        self.init(littleEndian: data.interpreted())
    }
}
