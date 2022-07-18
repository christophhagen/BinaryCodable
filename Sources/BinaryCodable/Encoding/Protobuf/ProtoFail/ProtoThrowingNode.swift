import Foundation

/**
 A class used when features are not supported for protobuf encoding.

 Any calls to encoding functions will fail with a `BinaryEncodingError.notProtobufCompatible` error
 */
class ProtoThrowingNode: AbstractEncodingNode, Encoder {

    let error: ProtobufEncodingError

    init(error: ProtobufEncodingError, path: [CodingKey], info: UserInfo) {
        self.error = error
        super.init(path: path, info: info)
    }

    init(from node: ProtoThrowingNode) {
        self.error = node.error
        super.init(path: node.codingPath, info: node.userInfo)
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let container = ProtoKeyedThrowingEncoder<Key>(from: self)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        ProtoUnkeyedThrowingEncoder(from: self)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        ProtoValueThrowingEncoder(from: self)
    }
}

extension ProtoThrowingNode: EncodingContainer {

    var isNil: Bool { false }

    var data: Data {
        .empty
    }

    var dataType: DataType {
        .byte
    }

    var isEmpty: Bool { false }
}
