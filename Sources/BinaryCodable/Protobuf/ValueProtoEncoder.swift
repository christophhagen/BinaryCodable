import Foundation

final class ValueProtoEncoder: AbstractProtoNode, SingleValueEncodingContainer {
    
    private var container: ProtoContainer?
    
    func encodeNil() throws {
        throw BinaryEncodingError.nilValuesNotSupported
    }
    
    private func assign(_ encoded: () throws -> ProtoContainer?) rethrows {
        guard container == nil else {
            incompatibilityReason = "Multiple values encoded into single value container"
            return
        }
        container = try encoded()
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            guard let protoPrimitive = primitive as? ProtobufEncodable else {
                throw BinaryEncodingError.unsupportedType(primitive)
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
            throw BinaryEncodingError.notProtobufCompatible("Single values are not supported")
        }
        guard let container = container else {
            throw BinaryEncodingError.notProtobufCompatible("No value encoded into single value container")
        }
        return try container.protobufDefinition()
    }

    var protoTypeName: String {
        container?.protoTypeName ?? "No container"
    }
}
