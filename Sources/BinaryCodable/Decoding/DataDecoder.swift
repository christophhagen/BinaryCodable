import Foundation

final class DataDecoder {

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
        let newIndex = index + count
        guard newIndex <= data.endIndex else {
            throw BinaryDecodingError.prematureEndOfData
        }
        defer { index = newIndex }
        return data[index..<newIndex]
    }

    func getVarint() throws -> Int {
        let data = try getDataOfVarint()
        return try .init(decodeFrom: data)
    }

    func getDataOfVarint() throws -> Data {
        let start = index
        for _ in 0...7 {
            guard index < data.endIndex else {
                throw BinaryDecodingError.prematureEndOfData
            }
            let byte = data[index]
            index += 1
            if byte & 0x80 == 0 {
                return data[start..<index]
            }
        }
        guard index < data.endIndex else {
            throw BinaryDecodingError.prematureEndOfData
        }
        index += 1
        return data[start..<index]
    }

    func getData(for dataType: DataType) throws -> Data {
        switch dataType {
        case .variableLengthInteger:
            return try getDataOfVarint()
        case .byte:
            return try getBytes(1)
        case .twoBytes:
            return try getBytes(2)
        case .variableLength:
            let count = try getVarint()
            return try getBytes(count)
        case .fourBytes:
            return try getBytes(4)
        case .eightBytes:
            return try getBytes(8)
        }
    }
}
