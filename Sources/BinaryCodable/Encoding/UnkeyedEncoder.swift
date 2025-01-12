import Foundation

struct UnkeyedEncoder: UnkeyedEncodingContainer {

    private let storage: UnkeyedEncoderStorage

    init(storage: UnkeyedEncoderStorage) {
        self.storage = storage
    }

    var codingPath: [any CodingKey] {
        storage.codingPath
    }

    var userInfo: UserInfo {
        storage.userInfo
    }

    var count: Int {
        storage.count
    }

    func encodeNil() throws {
        try storage.encodeNil()
    }

    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let storage = KeyedEncoderStorage(needsLengthData: true, codingPath: codingPath, userInfo: userInfo)
        self.storage.add(storage)
        return KeyedEncodingContainer(KeyedEncoder(storage: storage))
    }

    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let storage = UnkeyedEncoderStorage(needsLengthData: true, codingPath: codingPath, userInfo: userInfo)
        self.storage.add(storage)
        return UnkeyedEncoder(storage: storage)
    }

    func superEncoder() -> Encoder {
        storage.addedNode()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        try storage.encode(value)
    }
}
