import Foundation

struct CodingKeyWrapper {
    
    let codingKey: CodingKey
}

extension CodingKeyWrapper: Equatable {
    
    static func == (lhs: CodingKeyWrapper, rhs: CodingKeyWrapper) -> Bool {
        lhs.codingKey.stringValue == rhs.codingKey.stringValue
    }
}

extension CodingKeyWrapper: Hashable {
    
    func hash(into hasher: inout Hasher) {
        if let int = codingKey.intValue {
            hasher.combine(int)
        } else {
            hasher.combine(codingKey.stringValue)
        }
    }
}

extension CodingKeyWrapper: CustomStringConvertible {
    
    var description: String {
        if let int = codingKey.intValue {
            return codingKey.stringValue + " (\(int))"
        }
        return codingKey.stringValue
    }
}
