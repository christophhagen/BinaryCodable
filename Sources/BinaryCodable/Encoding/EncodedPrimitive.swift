import Foundation

struct EncodedPrimitive: EncodingContainer {
    
    let dataType: DataType

    let data: Data
    
    let isEmpty: Bool

    init(primitive: EncodablePrimitive) throws {
        self.dataType = primitive.dataType
        self.data = try primitive.data()
        self.isEmpty = false
    }

    init(protobuf: EncodablePrimitive, excludeDefaults: Bool = false) throws {
        guard protobuf.dataType.isProtobufCompatible else {
            throw ProtobufEncodingError.unsupported(type: protobuf)
        }
        guard let value = protobuf as? ProtobufEncodable else {
            throw ProtobufEncodingError.unsupported(type: protobuf)
        }
        if excludeDefaults && value.isZero {
            self.data = .empty
            self.isEmpty = true
        } else {
            self.data = try value.protobufData()
            self.isEmpty = false
        }
        self.dataType = protobuf.dataType
    }
}
