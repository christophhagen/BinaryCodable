import Foundation

extension Int32: EncodablePrimitive {
    
    func data() -> Data {
        zigZagEncoded
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension Int32: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        try self.init(fromZigZag: data, path: path)
    }
}

extension Int32: ZigZagCodable {

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

    init(fromZigZag data: Data, path: [CodingKey]) throws {
        let raw = try Int64(fromZigZag: data, path: path)
        guard let value = Int32(exactly: raw) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }
}

extension Int32: SignedValueCompatible {

    public var positiveProtoType: String {
        "int32"
    }
}
