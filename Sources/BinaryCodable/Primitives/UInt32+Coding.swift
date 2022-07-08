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

    init(decodeFrom data: Data) throws {
        try self.init(fromVarint: data)
    }
}

extension UInt32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    init(fromVarint data: Data) throws {
        let intValue = try UInt64(fromVarint: data)
        guard let value = UInt32(exactly: intValue) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }
}

extension UInt32: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .fourBytes
    }

    public var fixedProtoType: String {
        "fixed32"
    }

    public init(fromFixedSize data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        self = read(data: data, into: UInt32.zero)
    }

    public var fixedSizeEncoded: Data {
        let value = CFSwapInt32HostToLittle(self)
        return toData(value)
    }
}

extension UInt32: ProtobufCodable {

    func protobufData() -> Data {
        UInt64(self).protobufData()
    }

    init(fromProtobuf data: Data) throws {
        let intValue = try UInt64.init(fromProtobuf: data)
        guard let value = UInt32(exactly: intValue) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }

    var protoType: String { "uint32" }
}
