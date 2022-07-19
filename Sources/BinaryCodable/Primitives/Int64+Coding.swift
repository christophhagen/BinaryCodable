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

    init(decodeFrom data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

extension Int64: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(bitPattern: self).variableLengthEncoding
    }
    
    init(fromVarint data: Data) throws {
        let value = try UInt64(fromVarint: data)
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
    
    init(fromZigZag data: Data) throws {
        let unsigned = try UInt64(fromVarint: data)
        
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

extension Int64: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "sfixed64"
    }

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        let value = UInt64(littleEndian: read(data: data, into: UInt64.zero))
        self.init(bitPattern: value)
    }

    public var fixedSizeEncoded: Data {
        let value = UInt64(bitPattern: littleEndian)
        return toData(value)
    }
}

extension Int64: SignedValueCompatible {

    public var positiveProtoType: String {
        "int64"
    }
}

extension Int64: ProtobufEncodable {

    func protobufData() -> Data {
        variableLengthEncoding
    }

    var protoType: String { "sint64" }
}

extension Int64: ProtobufDecodable {

    init(fromProtobuf data: Data) throws {
        try self.init(fromVarint: data)
    }

}
