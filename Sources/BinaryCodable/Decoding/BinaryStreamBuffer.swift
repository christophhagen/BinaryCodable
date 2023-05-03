import Foundation

final class BinaryStreamBuffer {

    private let data: BinaryStreamProvider

    private var buffer: Data

    private var index: Data.Index

    init(data: BinaryStreamProvider) {
        self.data = data
        self.buffer = Data()
        self.index = 0
    }

    private func getBufferedBytes(_ count: Int) -> Data {
        let newIndex = index + count
        guard newIndex <= buffer.endIndex else {
            return buffer[index..<buffer.endIndex]
        }
        return buffer[index..<newIndex]
    }

    private func addToBuffer(_ data: Data) {
        buffer.append(data)
        index = buffer.endIndex
    }

    private func getAllRemainingBufferData() -> Data {
        guard index <= buffer.endIndex else {
            return Data()
        }
        return buffer[index..<buffer.endIndex]
    }

    func resetToBeginOfBuffer() {
        index = buffer.startIndex
    }

    func discardUsedBufferData() {
        buffer = Data()
        index = buffer.startIndex
    }
}

extension BinaryStreamBuffer: BinaryStreamProvider {

    func getBytes(_ count: Int, path: [CodingKey]) throws -> Data {
        let bufferedBytes = getBufferedBytes(count)
        let remaining = count - bufferedBytes.count
        guard remaining > 0 else {
            index += count
            return bufferedBytes
        }
        let remainingBytes = try data.getBytes(remaining, path: path)
        addToBuffer(remainingBytes)
        return bufferedBytes + remainingBytes
    }
    
    var hasMoreBytes: Bool {
        index < buffer.endIndex || data.hasMoreBytes
    }
}
