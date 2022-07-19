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

    init(decodeFrom data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

extension Int32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt32(bitPattern: self).variableLengthEncoding
    }
    
    init(fromVarint data: Data) throws {
        let value = try UInt32(fromVarint: data)
        self = Int32(bitPattern: value)
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

    init(fromZigZag data: Data) throws {
        let raw = try Int64(fromZigZag: data)
        guard let value = Int32(exactly: raw) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }
}

extension Int32: FixedSizeCompatible {

    public static var fixedSizeDataType: DataType {
        .fourBytes
    }

    public var fixedProtoType: String {
        "sfixed32"
    }

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        let value = UInt32(littleEndian: read(data: data, into: UInt32.zero))
        self.init(bitPattern: value)
    }

    public var fixedSizeEncoded: Data {
        let value = UInt32(bitPattern: littleEndian)
        return toData(value)
    }
}

extension Int32: SignedValueCompatible {

    public var positiveProtoType: String {
        "int32"
    }
}

extension Int32: ProtobufCodable {

    func protobufData() -> Data {
        Int64(self).protobufData()
    }

    init(fromProtobuf data: Data) throws {
        let intValue = try Int64(fromProtobuf: data)
        guard let value = Int32(exactly: intValue) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }

    var protoType: String { "sint32" }
}
