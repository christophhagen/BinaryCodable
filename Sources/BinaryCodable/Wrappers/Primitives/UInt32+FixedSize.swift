import Foundation

extension UInt32: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Data(underlying: littleEndian)
    }
}

extension UInt32: FixedSizeDecodable {

    public init(fromFixedSize data: Data, codingPath: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw DecodingError.invalidSize(size: data.count, for: "UInt32", codingPath: codingPath)
        }
        self.init(littleEndian: data.interpreted())
    }
}
