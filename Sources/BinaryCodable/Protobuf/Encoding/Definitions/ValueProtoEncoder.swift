import Foundation

final class ValueProtoEncoder: AbstractProtoNode, SingleValueEncodingContainer {
    
    private var container: ProtoContainer?
    
    func encodeNil() throws {
        throw ProtobufEncodingError.nilValuesNotSupported
    }
    
    private func assign(_ encoded: () throws -> ProtoContainer?) rethrows {
        guard container == nil else {
            encodingError = ProtobufEncodingError.multipleValuesInSingleValueContainer
            return
        }
        container = try encoded()
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            guard let protoPrimitive = primitive as? ProtobufEncodable else {
                throw ProtobufEncodingError.unsupported(type: primitive)
            }
            try assign {
                try ProtoPrimitive(primitive: protoPrimitive)
            }
            return
        }
        try assign {
            try ProtoNode(encoding: "\(type(of: value))", path: codingPath, info: userInfo).encoding(value)
        }
    }
}

extension ValueProtoEncoder: ProtoContainer {

    func protobufDefinition() throws -> String {
        if isRoot {
            throw ProtobufEncodingError.rootIsNotKeyedContainer
        }
        guard let container = container else {
            throw ProtobufEncodingError.noValueInSingleValueContainer
        }
        return try container.protobufDefinition()
    }

    var protoTypeName: String {
        container?.protoTypeName ?? "No container"
    }
}
