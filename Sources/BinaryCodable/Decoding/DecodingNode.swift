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

    init(data: Data, top: Bool = false, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.storage = .data(data)
        self.isAtTopLevel = top
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    init(decoder: DataDecoder, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.storage = .decoder(decoder)
        self.isAtTopLevel = false
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = try KeyedDecoder<Key>(data: storage.useAsData(), codingPath: codingPath, userInfo: userInfo)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedDecoder(data: storage.useAsData(), codingPath: codingPath, userInfo: userInfo)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ValueDecoder(
            data: storage.useAsDecoder(),
            top: isAtTopLevel,
            codingPath: codingPath,
            userInfo: userInfo)
    }
}
