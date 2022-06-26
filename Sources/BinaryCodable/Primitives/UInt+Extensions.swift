import Foundation

extension UInt: EncodablePrimitive {
    
    func data() throws -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension UInt: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> UInt {
        let intValue = try UInt64.readVariableLengthEncoded(from: data)
        guard let value = UInt(exactly: intValue) else {
            throw BinaryEncodingError.variableLengthEncodedIntegerOutOfRange
        }
        return value
    }
}
