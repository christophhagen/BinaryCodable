import Foundation

extension Int: FixedSizeCompatible {

    public static var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "sfixed64"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        let signed = try Int64(fromFixedSize: data, path: path)
        guard let value = Int(exactly: signed) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }

    public var fixedSizeEncoded: Data {
        Int64(self).fixedSizeEncoded
    }
}
