import Foundation

enum Storage {
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
