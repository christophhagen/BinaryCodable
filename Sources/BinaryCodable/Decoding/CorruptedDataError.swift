import Foundation

struct CorruptedDataError: Error {
    
    let description: String
    
    init(_ description: String) {
        self.description = description
    }
    
    init(invalidSize size: Int, for type: String) {
        self.description = "Invalid size \(size) for type \(type)"
    }
    
    static var prematureEndofData: CorruptedDataError {
        .init("Premature end of data")
    }
    
    static var variableLengthEncodedIntegerOutOfRange: CorruptedDataError {
        .init("Encoded variable-length integer out of range")
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
