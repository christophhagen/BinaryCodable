import Foundation

extension DecodingError {

    static func variableLengthEncodedIntegerOutOfRange(_ codingPath: [CodingKey]) -> DecodingError {
        corrupted("Encoded variable-length integer out of range", codingPath: codingPath)
    }

    static func notFound(_ key: CodingKey, codingPath: [CodingKey], _ message: String) -> DecodingError {
        .keyNotFound(key, .init(codingPath: codingPath, debugDescription: message))
    }

    static func valueNotFound(_ type: Any.Type, codingPath: [CodingKey], _ message: String) -> DecodingError {
        .valueNotFound(type, .init(codingPath: codingPath, debugDescription: message))
    }

    static func corrupted(_ message: String, codingPath: [CodingKey]) -> DecodingError {
        return .dataCorrupted(.init(codingPath: codingPath, debugDescription: message))
    }

    static func invalidSize(size: Int, for type: String, codingPath: [CodingKey]) -> DecodingError {
        .dataCorrupted(.init(codingPath: codingPath, debugDescription: "Invalid size \(size) for type \(type)"))
    }

    static func prematureEndOfData(_ codingPath: [CodingKey]) -> DecodingError {
        corrupted("Premature end of data", codingPath: codingPath)
    }
}
