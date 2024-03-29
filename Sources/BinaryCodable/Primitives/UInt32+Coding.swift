import Foundation

extension UInt32: EncodablePrimitive {
    
    func data() -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension UInt32: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        try self.init(fromVarint: data, path: path)
    }
}

extension UInt32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    init(fromVarint data: Data, path: [CodingKey]) throws {
        let intValue = try UInt64(fromVarint: data, path: path)
        guard let value = UInt32(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }
}
