import Foundation

private enum Storage {
    case data(Data)
    case decoder(DataDecoder)

    func useAsData() throws -> Data {
        switch self {
        case .data(let data):
            return data
        case .decoder(let decoder):
            return try decoder.getData(for: .variableLength)
        }
    }

    func useAsDecoder() -> DataDecoder {
        switch self {
        case .data(let data):
            return DataDecoder(data: data)
        case .decoder(let decoder):
            return decoder
        }
    }
}

final class DecodingNode: AbstractDecodingNode, Decoder {

    private let storage: Storage

    private let isAtTopLevel: Bool

    private let isNil: Bool

    init(data: Data, top: Bool = false, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.storage = .data(data)
        self.isAtTopLevel = top
        self.isNil = false
        super.init(codingPath: codingPath, options: options)
    }

    init(decoder: DataDecoder, isNil: Bool = false, codingPath: [CodingKey], options: Set<CodingOption>) {
        self.storage = .decoder(decoder)
        self.isNil = isNil
        self.isAtTopLevel = false
        super.init(codingPath: codingPath, options: options)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedDecoder<Key>(data: storage.useAsData(), codingPath: codingPath, options: options)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedDecoder(data: storage.useAsData(), codingPath: codingPath, options: options)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ValueDecoder(
            data: storage.useAsDecoder(),
            isNil: isNil,
            top: isAtTopLevel,
            codingPath: codingPath,
            options: options)
    }
}
