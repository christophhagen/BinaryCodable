import Foundation

final class ProtoUnkeyedThrowingEncoder: ProtoThrowingNode, UnkeyedEncodingContainer {

    var count: Int {
        0
    }

    func encodeNil() throws {
        throw error
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        throw error
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = ProtoKeyedThrowingEncoder<NestedKey>(from: self)
        return KeyedEncodingContainer(container)
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        ProtoUnkeyedThrowingEncoder(from: self)
    }

    func superEncoder() -> Encoder {
        ProtoThrowingNode(from: self)
    }
}
