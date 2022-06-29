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

extension UInt32: HostIndependentRepresentable {

    /// The little-endian representation
    var hostIndependentRepresentation: UInt32 {
        CFSwapInt32HostToLittle(self)
    }

    /**
     Create an `UInt32` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt32) {
        self = CFSwapInt32LittleToHost(value)
    }
}

extension UInt32: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .fourBytes
    }

    public var fixedProtoType: String {
        "fixed32"
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
