import Foundation

extension Int: EncodablePrimitive {
    
    func data() throws -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension Int: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        Int64(self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> Int {
        let intValue = try Int64.readVariableLengthEncoded(from: data)
        guard let value = Int(exactly: intValue) else {
            throw BinaryEncodingError.variableLengthEncodedIntegerOutOfRange
        }
        return value
    }
}
