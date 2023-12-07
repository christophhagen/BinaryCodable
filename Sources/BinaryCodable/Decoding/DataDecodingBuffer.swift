import Foundation

final class DataDecodingBuffer {

    private var buffer: Data

    private var index: Data.Index

    private(set) var didExceedBuffer = false

    init() {
        self.buffer = Data()
        self.index = 0
    }

    func addToBuffer(_ data: Data) {
        buffer.append(data)
        didExceedBuffer = false
    }

    func resetToBeginOfBuffer() {
        index = buffer.startIndex
        didExceedBuffer = false
    }

    func discardUsedBufferData() {
        buffer = buffer[index..<buffer.endIndex]
        index = buffer.startIndex
        didExceedBuffer = false
    }
    
    @discardableResult
    func discard(bytes: Int) -> Int {
        let bytesToRemove = min(buffer.count, bytes)
        buffer = buffer.dropFirst(bytesToRemove)
        index = buffer.startIndex
        return bytesToRemove
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

    func getBytes(_ count: Int, path: [CodingKey]) throws -> Data {
        let newIndex = index + count
        guard newIndex <= buffer.endIndex else {
            didExceedBuffer = true
            throw DecodingError.prematureEndOfData(path)
        }
        defer { index = newIndex }
        return buffer[index..<newIndex]
    }

    var hasMoreBytes: Bool {
        index < buffer.endIndex
    }
}
