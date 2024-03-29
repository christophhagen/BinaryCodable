import Foundation

extension Int64: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "sfixed64"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        let value = UInt64(littleEndian: read(data: data, into: UInt64.zero))
        self.init(bitPattern: value)
    }

    public var fixedSizeEncoded: Data {
        let value = UInt64(bitPattern: littleEndian)
        return toData(value)
    }
}
