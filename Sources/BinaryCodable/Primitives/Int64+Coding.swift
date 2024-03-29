import Foundation

extension Int64: EncodablePrimitive {
    
    func data() -> Data {
        zigZagEncoded
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension Int64: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        try self.init(fromZigZag: data, path: path)
    }
}

extension Int64: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(bitPattern: self).variableLengthEncoding
    }
    
    init(fromVarint data: Data, path: [CodingKey]) throws {
        let value = try UInt64(fromVarint: data, path: path)
        self = Int64(bitPattern: value)
    }
}

extension Int64: ZigZagEncodable {
    
    /**
     Encode a 64 bit signed integer using variable-length encoding.
     
     The sign of the value is extracted and appended as an additional bit.
     Positive signed values are thus encoded as `UInt(value) * 2`, and negative values as `UInt(abs(value) * 2 + 1`
     
     - Parameter value: The value to encode.
     - Returns: The value encoded as binary data (1 to 9 byte)
     */
    var zigZagEncoded: Data {
        guard self < 0 else {
            return (UInt64(self.magnitude) << 1).variableLengthEncoding
        }
        return ((UInt64(-1 - self) << 1) + 1).variableLengthEncoding
    }
}

extension Int64: ZigZagDecodable {
    
    init(fromZigZag data: Data, path: [CodingKey]) throws {
        let unsigned = try UInt64(fromVarint: data, path: path)
        
        // Check the last bit to get sign
        if unsigned & 1 > 0 {
            // Divide by 2 and subtract one to get absolute value of negative values.
            self = -Int64(unsigned >> 1) - 1
        } else {
            // Divide by two to get absolute value of positive values
            self = Int64(unsigned >> 1)
        }
    }
}

extension Int64: SignedValueCompatible {

    public var positiveProtoType: String {
        "int64"
    }
}
