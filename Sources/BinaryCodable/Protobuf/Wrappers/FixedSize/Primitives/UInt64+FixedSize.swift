import Foundation

extension UInt64: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "fixed64"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        self.init(littleEndian: read(data: data, into: UInt64.zero))
    }

    public var fixedSizeEncoded: Data {
        toData(littleEndian)
    }
}
