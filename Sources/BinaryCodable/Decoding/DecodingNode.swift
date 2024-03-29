import Foundation

/**
 A class acting as a decoder, to provide different containers for decoding.
 */
final class DecodingNode: AbstractDecodingNode, Decoder {

    private let data: Data?

    private var didCallContainer = false

    init(data: Data?, parentDecodedNil: Bool, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) throws {
        self.data = data
        super.init(parentDecodedNil: parentDecodedNil, codingPath: codingPath, userInfo: userInfo)
    }

    private func registerContainer() throws {
        guard !didCallContainer else {
            throw DecodingError.corrupted("Multiple containers requested from decoder", codingPath: codingPath)
        }
        didCallContainer = true
    }

    private func getNonNilElement() throws -> Data {
        try registerContainer()
        // Non-root containers just use the data, which can't be nil
        guard let data else {
            throw DecodingError.corrupted("Container requested, but nil found", codingPath: codingPath)
        }
        return data
    }

    private func getPotentialNilElement() throws -> Data? {
        try registerContainer()
        guard !parentDecodedNil else {
            return data
        }
        guard let data else {
            return nil
        }
        return try DecodingStorage(data: data, codingPath: codingPath)
            .decodeSingleElementWithNilIndicator()
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let data = try getNonNilElement()
        return KeyedDecodingContainer(try KeyedDecoder(data: data, codingPath: codingPath, userInfo: userInfo))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let data = try getNonNilElement()
        return try UnkeyedDecoder(data: data, codingPath: codingPath, userInfo: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        let data = try getPotentialNilElement()
        return ValueDecoder(data: data, codingPath: codingPath, userInfo: userInfo)
    }
}
