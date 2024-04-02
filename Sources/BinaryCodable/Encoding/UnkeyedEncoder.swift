import Foundation

final class UnkeyedEncoder: AbstractEncodingNode, UnkeyedEncodingContainer {

    private var encodedValues: [EncodableContainer] = []

    var count: Int {
        encodedValues.count
    }

    func encodeNil() throws {
        encodedValues.append(NilContainer())
    }

    @discardableResult
    private func add<T>(_ value: T) -> T where T: EncodableContainer {
        encodedValues.append(value)
        return value
    }

    private func addedNode() -> EncodingNode {
        let node = EncodingNode(needsLengthData: true, codingPath: codingPath, userInfo: userInfo)
        return add(node)
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(add(KeyedEncoder(needsLengthData: true, codingPath: codingPath, userInfo: userInfo)))
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        add(UnkeyedEncoder(needsLengthData: true, codingPath: codingPath, userInfo: userInfo))
    }

    func superEncoder() -> Encoder {
        addedNode()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        let encoded = try encodeValue(value, needsLengthData: true)
        add(encoded)
    }

}

extension UnkeyedEncoder: EncodableContainer {

    var needsNilIndicator: Bool {
        false
    }

    var isNil: Bool {
        false
    }

    func containedData() throws -> Data {
        try encodedValues.map {
            let data = try $0.completeData()
            return data
        }.joinedData
    }
}
