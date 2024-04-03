import Foundation

struct CorruptedDataError: Error {
    
    let description: String
    
    init(invalidSize size: Int, for type: String) {
        self.description = "Invalid size \(size) for type \(type)"
    }
    
    init(multipleValuesForKey key: DecodingKey) {
        self.description = "Multiple values for key '\(key)' in keyed container"
    }
    
    init(outOfRange value: CustomStringConvertible, forType type: String) {
        self.description = "Decoded value '\(value)' is out of range for type \(type)"
    }
    
    init(unusedBytes: Int, during process: String) {
        self.description = "Found \(unusedBytes) unused bytes during \(process)"
    }
    
    init(invalidBoolByte: UInt8) {
        self.description = "Found invalid boolean value '\(invalidBoolByte)'"
    }
    
    init(prematureEndofDataDecoding decodingStep: String) {
        self.description = "Premature end of data decoding \(decodingStep)"
    }
    
    init(invalidString length: Int) {
        self.description = "Non-UTF8 string found (\(length) bytes)"
    }
    
    func adding(codingPath: [CodingKey]) -> DecodingError {
        .corrupted(description, codingPath: codingPath)
    }
}

func wrapCorruptDataError<T>(at codingPath: [CodingKey] = [], _ closure: () throws -> T) rethrows -> T {
    do {
        return try closure()
    } catch let error as CorruptedDataError {
        throw error.adding(codingPath: codingPath)
    }
}
