import Foundation

extension Int32: FixedSizeCompatible {

    public static var fixedSizeDataType: DataType {
        .fourBytes
    }

    public var fixedProtoType: String {
        "sfixed32"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        let value = UInt32(littleEndian: read(data: data, into: UInt32.zero))
        self.init(bitPattern: value)
    }

    public var fixedSizeEncoded: Data {
        let value = UInt32(bitPattern: littleEndian)
        return toData(value)
    }
}
