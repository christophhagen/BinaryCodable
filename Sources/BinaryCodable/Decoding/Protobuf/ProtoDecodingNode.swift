import Foundation

class ProtoDecodingNode: AbstractDecodingNode, Decoder {

    let storage: Storage

    private let isAtTopLevel: Bool

    init(data: Data, top: Bool = false, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.storage = .data(data)
        self.isAtTopLevel = top
        super.init(codingPath: codingPath, options: options)
    }

    init(decoder: DataDecoder, isNil: Bool = false, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.storage = .decoder(decoder)
        self.isAtTopLevel = false
        super.init(codingPath: codingPath, options: options)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try ProtoKeyedDecoder<Key>(data: storage.useAsData(), codingPath: codingPath, options: options)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try ProtoUnkeyedDecoder(data: storage.useAsData(), codingPath: codingPath, options: options)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ProtoValueDecoder(
            data: storage.useAsDecoder(),
            top: isAtTopLevel,
            codingPath: codingPath,
            options: options)
    }
}
