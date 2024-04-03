import Foundation

/**
 A decoded key
 */
enum DecodingKey: Hashable {

    /// A decoded integer key
    case integer(Int)

    /// A decoded string key
    case string(String)

    func asKey<T>(_ type: T.Type = T.self) -> T? where T: CodingKey {
        switch self {
        case .integer(let int):
            return .init(intValue: int)
        case .string(let string):
            return .init(stringValue: string)
        }
    }
}

extension DecodingKey {

    /**
     Create a decoding key from an abstract coding key
     */
    init(key: CodingKey) {
        if let intValue = key.intValue {
            self = .integer(intValue)
        } else {
            self = .string(key.stringValue)
        }
    }
}

extension DecodingKey: ExpressibleByIntegerLiteral {

    init(integerLiteral value: IntegerLiteralType) {
        self = .integer(value)
    }
}

extension DecodingKey: ExpressibleByStringLiteral {

    init(stringLiteral value: StringLiteralType) {
        self = .string(value)
    }
}

extension DecodingKey: CustomStringConvertible {
    
    var description: String {
        switch self {
        case .integer(let int):
            return "\(int)"
        case .string(let string):
            return string
        }
    }
}
