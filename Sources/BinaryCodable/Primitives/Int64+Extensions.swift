import Foundation

extension Int64: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(bitPattern: self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> (value: Int64, consumedBytes: Int) {
        let decoded = try UInt64.readVariableLengthEncoded(from: data)
        return (value: Int64(bitPattern: decoded.value), consumedBytes: decoded.consumedBytes)
    }
}
