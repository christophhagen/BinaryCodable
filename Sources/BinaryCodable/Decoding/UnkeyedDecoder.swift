import Foundation

final class UnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    private let decoder: ByteStreamProvider

    private let nilIndices: Set<Int>

    init(data: Data, path: [CodingKey], info: UserInfo) throws {
        let decoder = DataDecoder(data: data)
        self.decoder = decoder
        if info.has(.prependNilIndicesForUnkeyedContainers) {
            let nilIndicesCount = try decoder.getVarint()
            guard nilIndicesCount >= 0 else {
                throw BinaryDecodingError.invalidDataSize
            }
            self.nilIndices = try (0..<nilIndicesCount)
                .map { _ in try decoder.getVarint() }
                .reduce(into: []) { $0.insert($1) }
        } else {
            self.nilIndices = []
        }
        super.init(path: path, info: info)
    }

    var count: Int? {
        nil
    }

    var isAtEnd: Bool {
        !nextValueIsNil && !decoder.hasMoreBytes
    }

    private(set) var currentIndex: Int = 0

    private var nextValueIsNil: Bool {
        if prependNilIndexSetForUnkeyedContainers {
            return nilIndices.contains(currentIndex)
        }
        return nextByteIndicatesNilValue
    }

    private var nextByteIndicatesNilValue: Bool {
        guard let byte = decoder.lookAtCurrentByte() else {
            return false
        }
        return byte == 0
    }

    func decodeNil() throws -> Bool {
        guard prependNilIndexSetForUnkeyedContainers else {
            // TODO: Should the decoder advance after the nil indicator byte?
            if nextByteIndicatesNilValue {
                // Skip the already checked nil indicator byte
                _ = try decoder.getByte()
                return true
            } else {
                return false
            }
        }
        guard nilIndices.contains(currentIndex) else {
            return false
        }
        currentIndex += 1
        return true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer { currentIndex += 1 }
        let isNil = nextValueIsNil
        if !prependNilIndexSetForUnkeyedContainers {
            // Skip the already checked nil indicator byte
            _ = try decoder.getByte()
        }
        if let Primitive = type as? DecodablePrimitive.Type {
            let dataType = Primitive.dataType
            let data = try decoder.getData(for: dataType)
            return try Primitive.init(decodeFrom: data) as! T
        }
        let node = DecodingNode(decoder: decoder, isNil: isNil, path: codingPath, info: userInfo)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        currentIndex += 1
        let data = try decoder.getData(for: .variableLength)
        let container = try KeyedDecoder<NestedKey>(data: data, path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        currentIndex += 1
        let data = try decoder.getData(for: .variableLength)
        return try UnkeyedDecoder(data: data, path: codingPath, info: userInfo)
    }

    func superDecoder() throws -> Decoder {
        currentIndex += 1
        return DecodingNode(decoder: decoder, path: codingPath, info: userInfo)
    }
}
