import Foundation

final class UnkeyedEncoderStorage: AbstractEncodingNode {

    private var encodedValues: [EncodableContainer] = []

    var count: Int {
        encodedValues.count
    }

    func encodeNil() throws {
        encodedValues.append(NilContainer())
    }

    @discardableResult
    func add<T>(_ value: T) -> T where T: EncodableContainer {
        encodedValues.append(value)
        return value
    }

    func addedNode() -> EncodingNode {
        let node = EncodingNode(needsLengthData: true, codingPath: codingPath, userInfo: userInfo)
        return add(node)
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        let encoded = try encodeValue(value, needsLengthData: true)
        add(encoded)
    }

}

extension UnkeyedEncoderStorage: EncodableContainer {

    var needsNilIndicator: Bool {
        false
    }

    var isNil: Bool {
        false
    }

    func containedData() throws -> Data {
        try encodedValues.mapAndJoin {
            try $0.completeData()
        }
    }
}
