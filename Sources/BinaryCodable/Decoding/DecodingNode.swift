import Foundation

final class DecodingNode: AbstractDecodingNode, Decoder {

    let data: Data

    init(data: Data, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedDecoder<Key>(data: data, codingPath: codingPath, userInfo: userInfo)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        try UnkeyedDecoder(data: data, codingPath: codingPath, userInfo: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        ValueDecoder(data: data, codingPath: codingPath, userInfo: userInfo)
    }
}
