import Foundation

extension UInt: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
    }
}

extension UInt: FixedSizeDecodable {

    public init(fromFixedSize data: Data, codingPath: [CodingKey]) throws {
        let intValue = try UInt64(fromFixedSize: data, codingPath: codingPath)
        guard let value = UInt(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(codingPath)
        }
        self = value
    }
}

