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
        return try decodeSingleElementWithNilIndicator(from: data)
    }
    
    /**
     Decode just the nil indicator byte, but don't extract a length. Uses all remaining bytes for the value.
     - Note: This function is only used for the root node
     */
    private func decodeSingleElementWithNilIndicator(from data: Data) throws -> Data? {
        guard let first = data.first else {
            throw DecodingError.corrupted("Premature end of data while decoding element with nil indicator", codingPath: codingPath)
        }
        // Check the nil indicator bit
        switch first {
        case 0:
            return data.dropFirst()
        case 1:
            guard data.count == 1 else {
                throw DecodingError.corrupted("\(data.count - 1) additional bytes found after nil indicator", codingPath: codingPath)
            }
            return nil
        default:
            throw DecodingError.corrupted("Found unexpected nil indicator \(first)", codingPath: codingPath)
        }
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
