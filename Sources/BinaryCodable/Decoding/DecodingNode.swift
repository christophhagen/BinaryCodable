import Foundation

final class DecodingNode: AbstractDecodingNode, Decoder {

    private let storage: Storage

    private let isOptional: Bool

    init(data: Data, isOptional: Bool = false, path: [CodingKey], info: UserInfo) {
        self.storage = .data(data)
        self.isOptional = isOptional
        super.init(path: path, info: info)
    }

    init(decoder: BinaryStreamProvider, isOptional: Bool = false, path: [CodingKey], info: UserInfo) {
        self.storage = .decoder(decoder)
        self.isOptional = isOptional
        super.init(path: path, info: info)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedDecoder<Key>(data: storage.useAsData(), path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedDecoder(data: storage.useAsData(), path: codingPath, info: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ValueDecoder(
            data: storage.useAsDecoder(),
            isOptional: isOptional,
            path: codingPath,
            info: userInfo)
    }
}
