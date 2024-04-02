import Foundation

final class UnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    var count: Int? { data.count }

    var isAtEnd: Bool { currentIndex >= data.count }

    private(set) var currentIndex: Int = 0

    private let data: [Data?]

    init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
        self.data = try DecodingStorage(data: data, codingPath: codingPath).decodeUnkeyedElements()
        super.init(parentDecodedNil: true, codingPath: codingPath, userInfo: userInfo)
    }

    /// Get the next element without advancing the index.
    private func ensureNextElement() throws -> Data? {
        guard currentIndex < data.count else {
            throw DecodingError.corrupted("No more elements to decode", codingPath: codingPath)
        }
        return data[currentIndex]
    }

    /// Get the next element and advance the index.
    private func nextElement() throws -> Data? {
        let element = try ensureNextElement()
        currentIndex += 1
        return element
    }

    private func nextNode() throws -> DecodingNode {
        let element = try nextElement()
        return try DecodingNode(data: element, parentDecodedNil: true, codingPath: codingPath, userInfo: userInfo)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedDecodingContainer(try nextNode().container(keyedBy: type))
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        try nextNode().unkeyedContainer()
    }

    func superDecoder() throws -> Decoder {
        try nextNode()
    }

    func decodeNil() throws -> Bool {
        if try ensureNextElement() == nil {
            currentIndex += 1
            return true
        }
        return false
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let element = try nextElement()
        return try decode(element: element, type: type, codingPath: codingPath)
    }
}
