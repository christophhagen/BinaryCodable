import Foundation

extension Int32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt32(bitPattern: self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> (value: Int32, consumedBytes: Int) {
        let decoded = try UInt32.readVariableLengthEncoded(from: data)
        return (value: Int32(bitPattern: decoded.value), consumedBytes: decoded.consumedBytes)
    }
}
