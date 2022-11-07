import Foundation

final class DataDecodingBuffer {

    private var buffer: Data

    private var index: Data.Index

    init() {
        self.buffer = Data()
        self.index = 0
    }

    func addToBuffer(_ data: Data) {
        buffer.append(data)
    }

    func resetToBeginOfBuffer() {
        index = buffer.startIndex
    }

    func discardUsedBufferData() {
        buffer = buffer[index..<buffer.endIndex]
        index = buffer.startIndex
    }

    var totalBufferSize: Int {
        buffer.count
    }

    var unusedBytes: Int {
        buffer.endIndex - index
    }
}

// MARK: BinaryStreamProvider

extension DataDecodingBuffer: BinaryStreamProvider {

    func getBytes(_ count: Int) throws -> Data {
        let newIndex = index + count
        guard newIndex <= buffer.endIndex else {
            throw BinaryDecodingError.prematureEndOfData
        }
        defer { index = newIndex }
        return buffer[index..<newIndex]
    }

    var hasMoreBytes: Bool {
        index < buffer.endIndex
    }
}
