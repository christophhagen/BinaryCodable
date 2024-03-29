import Foundation

extension UInt: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "fixed64"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        let intValue = try UInt64(fromFixedSize: data, path: path)
        guard let value = UInt(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }

    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
    }
}

