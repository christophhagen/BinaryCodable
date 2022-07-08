import Foundation

struct EncodedPrimitive: EncodingContainer {
    
    let dataType: DataType

    let data: Data

    init(primitive: EncodablePrimitive) throws {
        self.dataType = primitive.dataType
        self.data = try primitive.data()
    }

    init(protobuf: EncodablePrimitive) throws {
        guard protobuf.dataType.isProtobufCompatible else {
            throw BinaryEncodingError.unsupportedType(protobuf)
        }
        guard let value = protobuf as? ProtobufEncodable else {
            throw BinaryEncodingError.unsupportedType(protobuf)
        }
        self.data = try value.protobufData()
        self.dataType = protobuf.dataType
    }
}
