import Foundation

/**
 A class used when features are not supported for protobuf encoding.

 Any calls to encoding functions will fail with a `BinaryEncodingError.notProtobufCompatible` error
 */
class ProtoThrowingNode: AbstractEncodingNode, Encoder {

    let error: BinaryEncodingError

    convenience init(reason: String, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.init(error: .notProtobufCompatible(reason), codingPath: codingPath, options: options)
    }

    init(error: BinaryEncodingError, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.error = error
        super.init(codingPath: codingPath, options: options)
    }

    init(from node: ProtoThrowingNode) {
        self.error = node.error
        super.init(codingPath: node.codingPath, options: node.options)
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
