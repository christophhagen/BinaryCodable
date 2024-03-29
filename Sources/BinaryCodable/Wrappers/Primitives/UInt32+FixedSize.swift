import Foundation

extension UInt32: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .fourBytes
    }

    public var fixedProtoType: String {
        "fixed32"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        self.init(littleEndian: read(data: data, into: UInt32.zero))
    }

    public var fixedSizeEncoded: Data {
        toData(littleEndian)
    }
}
