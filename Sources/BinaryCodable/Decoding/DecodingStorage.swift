import Foundation

final class DecodingStorage {

    let codingPath: [CodingKey]

    private let data: Data

    private var index: Data.Index

    init(data: Data, codingPath: [CodingKey]) {
        self.codingPath = codingPath
        self.data = data
        self.index = data.startIndex
    }
}

extension DecodingStorage: DecodingDataProvider {

    var isAtEnd: Bool {
        index >= data.endIndex
    }

    func nextByte() throws -> UInt64 {
        guard !isAtEnd else {
            throw corrupted("Missing byte(s) decoding variable length integer")
        }
        defer { index += 1 }
        return UInt64(data[index])
    }

    var numberOfRemainingBytes: Int {
        data.endIndex - index
    }

    func getBytes(_ count: Int) throws -> Data {
        let newIndex = index + count
        guard newIndex <= data.endIndex else {
            throw corrupted("Unexpected end of data")
        }
        defer { index = newIndex }
        return data[index..<newIndex]
    }
}
