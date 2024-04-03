import Foundation

extension UInt: FixedSizeEncodable {

    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
    }
}

extension UInt: FixedSizeDecodable {

    public init(fromFixedSize data: Data) throws {
        let intValue = try UInt64(fromFixedSize: data)
        guard let value = UInt(exactly: intValue) else {
            throw CorruptedDataError(outOfRange: intValue, forType: "UInt")
        }
        self = value
    }
}

