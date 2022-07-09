import Foundation

final class KeyedProtoEncoder<Key>: AbstractProtoNode, KeyedEncodingContainerProtocol where Key: CodingKey {
    
    var content = [ProtoKeyWrapper : ProtoContainer]()
    
    @discardableResult
    func assign<T>(to key: CodingKey, container: () throws -> T) rethrows -> T where T: ProtoContainer {
        let wrapped = ProtoKeyWrapper(key)
        guard content[wrapped] == nil else {
            fatalError("Multiple values encoded for key \(key)")
        }
        let value = try container()
        content[wrapped] = value
        return value
    }
    
    func encodeNil(forKey key: Key) throws {
        throw ProtobufEncodingError.nilValuesNotSupported
    }
    
    func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            guard let protoPrimitive = primitive as? ProtobufEncodable else {
                throw ProtobufEncodingError.unsupported(type: primitive)
            }
            try assign(to: key) {
                try ProtoPrimitive(primitive: protoPrimitive)
            }
            return
        }
        try assign(to: key) {
            try ProtoNode(encoding: "\(type(of: value))", path: codingPath, info: userInfo)
                .encoding(value)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign(to: key) {
            KeyedProtoEncoder<NestedKey>(encoding: encodedType, path: codingPath + [key], info: userInfo)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        assign(to: key) {
            UnkeyedProtoEncoder(encoding: encodedType, path: codingPath + [key], info: userInfo)
        }
    }
    
    func superEncoder() -> Encoder {
        fatalError("Protobuf compatibility does not support encoding super")
    }
    
    func superEncoder(forKey key: Key) -> Encoder {
        fatalError("Protobuf compatibility does not support encoding super")
    }
}


extension KeyedProtoEncoder: ProtoContainer {

    func protobufDefinition() throws -> String {

        let prefix = "message \(encodedType) {\n\n"

        let fields = try content
            .sorted { $0.key < $1.key }
            .map { key, value -> String in
                guard let field = key.intValue else {
                    throw ProtobufEncodingError.missingIntegerKey(key.stringValue)
                }
                // TODO: Add additional message definitions
                // The protobuf description needs to print also nested messages
                // Currently, only the top level is shown
                // This requires additional methods on the hierarchy to get all nested definitions
                // within a container.
                return "\(value.protoTypeName) \(key.stringValue) = \(field);"
            }
            .joined(separator: "\n\n").indented()
        let suffix = "\n}"
        return prefix + fields + suffix
    }

    var protoTypeName: String {
        encodedType
    }
}
