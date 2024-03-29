import Foundation

extension Int: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Int64(self).fixedSizeEncoded
    }
}

extension Int: FixedSizeDecodable {

    public init(fromFixedSize data: Data, codingPath: [CodingKey]) throws {
        let signed = try Int64(fromFixedSize: data, codingPath: codingPath)
        guard let value = Int(exactly: signed) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(codingPath)
        }
        self = value
    }
}
