import Foundation

final class UnkeyedProtoEncoder: AbstractProtoNode, UnkeyedEncodingContainer {
    
    var count: Int {
        content.count
    }
    
    private var content = [ProtoContainer]()

    @discardableResult
    private func assign<T>(_ encoded: () throws -> T) rethrows -> T where T: ProtoContainer {
        let value = try encoded()
        if let existingType = content.first?.protoTypeName, existingType != value.protoTypeName {
            incompatibilityReason = "All values in unkeyed containers must be of the same type"
        }
        content.append(value)
        return value
    }
    
    func encodeNil() throws {
        throw BinaryEncodingError.nilValuesNotSupported
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
            try ProtoNode(encoding: "\(type(of: value))", path: codingPath, info: userInfo)
                .encoding(value)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign {
            KeyedProtoEncoder<NestedKey>(encoding: encodedType, path: codingPath, info: userInfo)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assign {
            UnkeyedProtoEncoder(encoding: encodedType, path: codingPath, info: userInfo)
        }
    }
    
    func superEncoder() -> Encoder {
        incompatibilityReason = "Super encoding is not supported"
        return ProtoNode(encoding: encodedType, path: codingPath, info: userInfo)
    }
}

extension UnkeyedProtoEncoder: ProtoContainer {

    func protobufDefinition() throws -> String {
        if isRoot {
            throw BinaryEncodingError.notProtobufCompatible("Top-level unkeyed values are not supported")
        }
        if let reason = incompatibilityReason {
            throw BinaryEncodingError.notProtobufCompatible(reason)
        }
        guard let def = try content.first?.protobufDefinition() else {
            throw BinaryEncodingError.notProtobufCompatible("No value in unkeyed container to determine type")
        }
        return def
    }

    var protoTypeName: String {
       "repeated " + (content.first?.protoTypeName ?? "")
    }
}
