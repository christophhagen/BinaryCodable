import Foundation

final class DecodingNode: AbstractDecodingNode, Decoder {

    private let storage: Storage

    private let isOptional: Bool
    
    private let isInUnkeyedContainer: Bool

    init(storage: Storage, isOptional: Bool = false, path: [CodingKey], info: UserInfo, isInUnkeyedContainer: Bool = false) {
        self.storage = storage
        self.isOptional = isOptional
        self.isInUnkeyedContainer = isInUnkeyedContainer
        super.init(path: path, info: info)
    }

    init(data: Data, isOptional: Bool = false, path: [CodingKey], info: UserInfo) {
        self.storage = .data(data)
        self.isOptional = isOptional
        self.isInUnkeyedContainer = false
        super.init(path: path, info: info)
    }

    init(decoder: BinaryStreamProvider, isOptional: Bool = false, path: [CodingKey], info: UserInfo, isInUnkeyedContainer: Bool = false) {
        self.storage = .decoder(decoder)
        self.isOptional = isOptional
        self.isInUnkeyedContainer = isInUnkeyedContainer
        super.init(path: path, info: info)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedDecoder<Key>(data: storage.useAsData(path: codingPath), path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedDecoder(data: storage.useAsData(path: codingPath), path: codingPath, info: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ValueDecoder(
            storage: storage,
            isOptional: isOptional, 
            isInUnkeyedContainer: isInUnkeyedContainer,
            path: codingPath,
            info: userInfo)
    }
}
