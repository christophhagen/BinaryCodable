import Foundation

final class UnkeyedDecoder: AbstractDecodingNode, UnkeyedDecodingContainer {

    private let decoder: BinaryStreamProvider

    private let nilIndices: Set<Int>

    init(data: Data, path: [CodingKey], info: UserInfo) throws {
        let decoder = DataDecoder(data: data)
        self.decoder = decoder
        if info.has(.prependNilIndicesForUnkeyedContainers) {
            let nilIndicesCount = try decoder.getVarint(path: path)
            guard nilIndicesCount >= 0 else {
                throw DecodingError.invalidDataSize(path)
            }
            self.nilIndices = try (0..<nilIndicesCount)
                .map { _ in try decoder.getVarint(path: path) }
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
        nilIndices.contains(currentIndex)
    }

    func decodeNil() throws -> Bool {
        guard prependNilIndexSetForUnkeyedContainers else {
            fatalError("Use option `containsNilIndexSetForUnkeyedContainers` to use `decodeNil()`")
        }
        guard nilIndices.contains(currentIndex) else {
            return false
        }
        currentIndex += 1
        return true
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        defer { currentIndex += 1 }
        return try wrapError {
            if type is AnyOptional.Type {
                let node = DecodingNode(decoder: decoder, isOptional: true, path: codingPath, info: userInfo, isInUnkeyedContainer: true)
                return try T.init(from: node)
            } else if let Primitive = type as? DecodablePrimitive.Type {
                let dataType = Primitive.dataType
                let data = try decoder.getData(for: dataType, path: codingPath)
                return try Primitive.init(decodeFrom: data, path: codingPath) as! T
            } else {
                let node = DecodingNode(decoder: decoder, path: codingPath, info: userInfo, isInUnkeyedContainer: true)
                return try T.init(from: node)
            }
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        currentIndex += 1
        return try wrapError {
            let data = try decoder.getData(for: .variableLength, path: codingPath)
            let container = try KeyedDecoder<NestedKey>(data: data, path: codingPath, info: userInfo)
            return KeyedDecodingContainer(container)
        }
    }

    func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        currentIndex += 1
        return try wrapError {
            let data = try decoder.getData(for: .variableLength, path: codingPath)
            return try UnkeyedDecoder(data: data, path: codingPath, info: userInfo)
        }
    }

    func superDecoder() throws -> Decoder {
        currentIndex += 1
        return DecodingNode(decoder: decoder, path: codingPath, info: userInfo, isInUnkeyedContainer: true)
    }

    private func wrapError<T>(_ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch DecodingError.dataCorrupted(let context) {
            var codingPath = codingPath
            codingPath.append(AnyCodingKey(intValue: currentIndex))
            codingPath.append(contentsOf: context.codingPath)
            let newContext = DecodingError.Context(
                codingPath: codingPath,
                debugDescription: context.debugDescription,
                underlyingError: context.underlyingError
            )
            throw DecodingError.dataCorrupted(newContext)
        }
    }
}
