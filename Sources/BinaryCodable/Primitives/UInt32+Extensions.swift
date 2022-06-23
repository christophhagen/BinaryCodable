import Foundation

extension UInt32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> (value: UInt32, consumedBytes: Int) {
        let (intValue, consumedBytes) = try UInt64.readVariableLengthEncoded(from: data)
        guard let value = UInt32(exactly: intValue) else {
            throw BinaryEncodingError.variableLengthEncodedIntegerOutOfRange
        }
        return (value: value, consumedBytes: consumedBytes)
    }
}
