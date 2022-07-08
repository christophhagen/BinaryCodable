import Foundation

final class ProtoDictUnkeyedEncoder: AbstractEncodingNode, UnkeyedEncodingContainer {

    var count: Int {
        content.count
    }

    private var content = [NonNilEncodingContainer]()

    private var key: NonNilEncodingContainer?

    private func assign<T>(_ value: T) where T: NonNilEncodingContainer {
        if let key = key {
            let pair = ProtoDictPair(key: key, value: value)
            content.append(pair)
            self.key = nil
        } else {
            key = value
        }
    }

    func encodeNil() throws {
        throw BinaryEncodingError.nilValuesNotSupported
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            // Ensure that only same-type values are encoded
//            if forceProtobufCompatibility {
//                #warning("Improve detection of same types")
//                if let first = content.first, first.dataType != primitive.dataType {
//                    throw BinaryEncodingError.notProtobufCompatible("All values in unkeyed containers must have the same type")
//                }
//            }
            let node = try EncodedPrimitive(protobuf: primitive)
            assign(node)
            return
        }
        let node = try ProtoEncodingNode(codingPath: codingPath, options: options).encoding(value)
        assign(node)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ProtoKeyedThrowingEncoder<NestedKey>(
            reason: "Nested containers not supported for dictionaries",
            codingPath: codingPath, options: options)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        ProtoUnkeyedThrowingEncoder(
            reason: "Nested containers not supported for dictionaries",
            codingPath: codingPath, options: options)
    }

    func superEncoder() -> Encoder {
        ProtoThrowingNode(error: .superNotSupported, codingPath: codingPath, options: options)
    }
}

extension ProtoDictUnkeyedEncoder: NonNilEncodingContainer {

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        content
            .map { $0.encodeWithKey(key) }
            .joinedData
    }

    var data: Data {
        content.map { $0.dataWithLengthInformationIfRequired }.joinedData
    }

    var dataType: DataType {
        .variableLength
    }

    var isEmpty: Bool {
        content.isEmpty
    }
}
