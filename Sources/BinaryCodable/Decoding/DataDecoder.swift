import Foundation

struct DataDecoder {

    let data: Data

    var index: Data.Index

    init(data: Data) {
        self.data = data
        self.index = data.startIndex
    }

    var hasMoreBytes: Bool {
        index < data.endIndex
    }

    mutating func getByte() throws -> UInt8 {
        try getBytes(1)[0]
    }

    mutating func getBytes(_ count: Int) throws -> Data {
        let newIndex = index + count
        guard newIndex <= data.endIndex else {
            throw BinaryDecodingError.prematureEndOfData
        }
        defer { index = newIndex }
        return data[index..<newIndex]
    }

    mutating func getVarint() throws -> Int {
        let data = try getDataOfVarint()
        return try .init(decodeFrom: data)
    }

    mutating func getDataOfVarint() throws -> Data {
        let count = try readByteCountOfVarint()
        defer { index += count }
        return data[index..<index+count]
    }

    mutating func readByteCountOfVarint() throws -> Int {
        for offset in 0...8 {
            guard index + offset <= data.endIndex else {
                throw BinaryDecodingError.prematureEndOfData
            }
            if data[index + offset] & 0x80 == 0 {
                return offset + 1
            }
        }
        guard index + 9 <= data.endIndex else {
            throw BinaryDecodingError.prematureEndOfData
        }
        return 9
    }

    mutating func getData(for dataType: DataType) throws -> Data {
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
