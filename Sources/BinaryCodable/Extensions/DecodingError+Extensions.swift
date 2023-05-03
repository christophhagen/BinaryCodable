import Foundation

extension DecodingError {

    static func variableLengthEncodedIntegerOutOfRange(_ path: [CodingKey]) -> DecodingError {
        corruptedError(path, description: "Encoded variable-length integer out of range")
    }

    static func invalidDataSize(_ path: [CodingKey]) -> DecodingError {
        corruptedError(path, description: "Invalid data size")
    }

    static func multipleValuesForKey(_ path: [CodingKey], _ key: DecodingKey) -> DecodingError {
        corruptedError(path, description: "Multiple values for key \(key)")
    }

    static func prematureEndOfData(_ path: [CodingKey]) -> DecodingError {
        corruptedError(path, description: "Premature end of data")
    }

    private static func corruptedError(_ path: [CodingKey], description: String) -> DecodingError {
        let context = DecodingError.Context(codingPath: path, debugDescription: description)
        return .dataCorrupted(context)
    }

}
