import Foundation

enum Storage {
    case data(Data)
    case decoder(BinaryStreamProvider)

    func useAsData() throws -> Data {
        switch self {
        case .data(let data):
            return data
        case .decoder(let decoder):
            return try decoder.getData(for: .variableLength)
        }
    }

    func useAsDecoder() -> BinaryStreamProvider {
        switch self {
        case .data(let data):
            return DataDecoder(data: data)
        case .decoder(let decoder):
            return decoder
        }
    }
}
