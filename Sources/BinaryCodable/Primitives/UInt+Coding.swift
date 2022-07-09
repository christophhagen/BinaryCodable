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

extension UInt: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "fixed64"
    }

    public init(fromFixedSize data: Data) throws {
        let intValue = try UInt64(fromFixedSize: data)
        guard let value = UInt(exactly: intValue) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }

    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
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

extension UInt: ProtobufEncodable {

    func protobufData() -> Data {
        variableLengthEncoding
    }

    var protoType: String { "uint64" }
}

extension UInt: ProtobufDecodable {

    init(fromProtobuf data: Data) throws {
        try self.init(fromVarint: data)
    }

}
