import Foundation

extension UInt: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> (value: UInt, consumedBytes: Int) {
        let (intValue, consumedBytes) = try UInt64.readVariableLengthEncoded(from: data)
        guard let value = UInt(exactly: intValue) else {
            throw BinaryEncodingError.variableLengthEncodedIntegerOutOfRange
        }
        return (value: value, consumedBytes: consumedBytes)
    }
}
