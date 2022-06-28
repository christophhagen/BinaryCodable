import Foundation

extension Int: EncodablePrimitive {
    
    func data() -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension Int: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        self = try Int.readVariableLengthEncoded(from: data)
    }
}

extension Int: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        Int64(self).variableLengthEncoding
    }
    
    init(fromVarint data: Data) throws {
        let intValue = try Int64(fromVarint: data)
        guard let value = Int(exactly: intValue) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        return value
        self = value
    }
}
    }
}
