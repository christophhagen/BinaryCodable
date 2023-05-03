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

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        try self.init(fromZigZag: data, path: path)
    }
}

extension Int: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        Int64(self).variableLengthEncoding
    }
    
    init(fromVarint data: Data, path: [CodingKey]) throws {
        let intValue = try Int64(fromVarint: data, path: path)
        guard let value = Int(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }
}

extension Int: FixedSizeCompatible {

    public static var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "sfixed64"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        let signed = try Int64(fromFixedSize: data, path: path)
        guard let value = Int(exactly: signed) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }

    public var fixedSizeEncoded: Data {
        Int64(self).fixedSizeEncoded
    }
}

extension Int: SignedValueCompatible {

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

    init(fromZigZag data: Data, path: [CodingKey]) throws {
        let raw = try Int64(fromZigZag: data, path: path)
        guard let value = Int(exactly: raw) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }
}

extension Int: ProtobufEncodable {

    func protobufData() -> Data {
        variableLengthEncoding
    }

    var protoType: String { "sint64" }
}

extension Int: ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(fromVarint: data, path: path)
    }
}
