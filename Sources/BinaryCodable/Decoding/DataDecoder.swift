import Foundation

final class DataDecoder: ByteStreamProvider {

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

    func getBytes(_ count: Int) throws -> Data {
        guard count >= 0 else {
            throw BinaryDecodingError.invalidDataSize
        }
        let newIndex = index + count
        guard newIndex <= data.endIndex else {
            throw BinaryDecodingError.prematureEndOfData
        }
        defer { index = newIndex }
        return data[index..<newIndex]
    }

    func lookAtCurrentByte() -> UInt8? {
        guard hasMoreBytes else {
            return nil
        }
        return data[index]
    }
}
