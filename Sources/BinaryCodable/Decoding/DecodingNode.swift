import Foundation

final class DecodingNode: AbstractDecodingNode, Decoder {

    private let storage: Storage

    private let isAtTopLevel: Bool

    private let isNil: Bool

    init(data: Data, top: Bool = false, path: [CodingKey], info: UserInfo) {
        self.storage = .data(data)
        self.isAtTopLevel = top
        self.isNil = false
        super.init(path: path, info: info)
    }

    init(decoder: BinaryStreamProvider, isNil: Bool = false, path: [CodingKey], info: UserInfo) {
        self.storage = .decoder(decoder)
        self.isNil = isNil
        self.isAtTopLevel = false
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
            isNil: isNil,
            top: isAtTopLevel,
            path: codingPath,
            info: userInfo)
    }
}
