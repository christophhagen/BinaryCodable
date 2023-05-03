import Foundation

final class DataDecoder: BinaryStreamProvider {

    let data: Data

    var index: Data.Index

    init(data: Data) {
        self.data = data
        self.index = data.startIndex
    }

    var hasMoreBytes: Bool {
        index < data.endIndex
    }

    func getAllData() -> Data {
        data
    }

    func getBytes(_ count: Int, path: [CodingKey]) throws -> Data {
        let newIndex = index + count
        guard newIndex <= data.endIndex else {
            throw DecodingError.prematureEndOfData(path)
        }
        defer { index = newIndex }
        return data[index..<newIndex]
    }
}
