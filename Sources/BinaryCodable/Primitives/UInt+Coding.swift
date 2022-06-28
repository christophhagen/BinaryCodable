import Foundation

extension UInt: EncodablePrimitive {
    
    func data() -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension UInt: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        try self.init(fromVarint: data)
    }
}

extension UInt: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    init(fromVarint data: Data) throws {
        let intValue = try UInt64(fromVarint: data)
        guard let value = UInt(exactly: intValue) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }
}
