import Foundation

extension Int: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        Int64(self).fixedSizeEncoded
    }
}

extension Int: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        let signed = try Int64(fromFixedSize: data)
        guard let value = Int(exactly: signed) else {
            throw CorruptedDataError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }
}
