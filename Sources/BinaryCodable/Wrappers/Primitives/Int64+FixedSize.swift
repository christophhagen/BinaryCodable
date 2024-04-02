import Foundation

extension Int64: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        let value = UInt64(bitPattern: littleEndian)
        return Data.init(underlying: value)
    }
}

extension Int64: FixedSizeDecodable {

    public init(fromFixedSize data: Data, codingPath: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw DecodingError.invalidSize(size: data.count, for: "Int64", codingPath: codingPath)
        }
        let value = UInt64(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
