import Foundation

struct EncodedPrimitive: EncodingContainer {
    
    let dataType: DataType

    let data: Data

    init(primitive: EncodablePrimitive, protobuf: Bool) throws {
        self.dataType = primitive.dataType
        if protobuf {
            guard primitive.dataType.isProtobufCompatible else {
                throw BinaryEncodingError.notProtobufCompatible
            }
            guard let value = primitive as? ProtobufEncodable else {
                throw BinaryEncodingError.notProtobufCompatible
            }
            self.data = try value.protobufData()
        } else {
            self.data = try primitive.data()
        }
    }
}
