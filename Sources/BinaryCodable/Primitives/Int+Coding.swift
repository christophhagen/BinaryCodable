import Foundation

extension Int: EncodablePrimitive {
    
    func data() -> Data {
        zigZagEncoded
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension Int: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        try self.init(fromZigZag: data)
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
        self = value
    }
}

extension Int: PositiveIntegerCompatible {

    public var positiveProtoType: String {
        "int64"
    }
}

extension Int: ZigZagCodable {

    /**
     Encode a 64 bit signed integer using variable-length encoding.

     The sign of the value is extracted and appended as an additional bit.
     Positive signed values are thus encoded as `UInt(value) * 2`, and negative values as `UInt(abs(value) * 2 + 1`

     - Parameter value: The value to encode.
     - Returns: The value encoded as binary data (1 to 9 byte)
     */
    var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }

    init(fromZigZag data: Data) throws {
        let raw = try Int64(fromZigZag: data)
        guard let value = Int(exactly: raw) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }
}
