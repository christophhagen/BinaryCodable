import Foundation

extension Data: DecodingDataProvider {
    
    func isAtEnd(at index: Index) -> Bool {
        index >= endIndex
    }
    
    func nextByte(at index: inout Index) -> UInt8? {
        guard index < endIndex else {
            return nil
        }
        defer { index += 1 }
        return self[index]
    }
    
    func nextBytes(_ count: Int, at index: inout Index) -> Data? {
        let newEndIndex = index + count
        guard newEndIndex <= endIndex else {
            return nil
        }
        defer { index = newEndIndex }
        return self[index..<newEndIndex]
    }
}
