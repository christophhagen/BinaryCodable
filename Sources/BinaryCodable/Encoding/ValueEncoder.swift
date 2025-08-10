import Foundation

struct ValueEncoder: SingleValueEncodingContainer {

    var codingPath: [any CodingKey] {
        storage.codingPath
    }

    private var storage: ValueEncoderStorage

    init(storage: ValueEncoderStorage) {
        self.storage = storage
    }

    func encodeNil() throws {
        try storage.encodeNil()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        try storage.encode(value)
    }
}
