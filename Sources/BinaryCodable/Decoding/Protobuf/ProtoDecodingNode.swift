import Foundation

class ProtoDecodingNode: AbstractDecodingNode, Decoder {

    let storage: Storage

    init(data: Data, path: [CodingKey], info: UserInfo) {
        self.storage = .data(data)
        super.init(path: path, info: info)
    }

    init(decoder: DataDecoder, path: [CodingKey], info: UserInfo) {
        self.storage = .decoder(decoder)
        super.init(path: path, info: info)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try ProtoKeyedDecoder<Key>(data: storage.useAsData(), path: codingPath, info: userInfo)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try ProtoUnkeyedDecoder(data: storage.useAsData(), path: codingPath, info: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ProtoValueDecoder(
            data: storage.useAsDecoder(),
            path: codingPath,
            info: userInfo)
    }
}
