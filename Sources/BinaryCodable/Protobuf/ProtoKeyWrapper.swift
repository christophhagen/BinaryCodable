import Foundation

/**
 A wrapper around a coding key to allow usage in dictionaries.
 */
struct ProtoKeyWrapper {
    
    let intValue: Int?

    let stringValue: String

    /**
     Create a wrapper around a coding key.
     */
    init(_ codingKey: CodingKey) {
        self.intValue = codingKey.intValue
        self.stringValue = codingKey.stringValue
    }
}

extension ProtoKeyWrapper: Equatable {
    
    static func == (lhs: ProtoKeyWrapper, rhs: ProtoKeyWrapper) -> Bool {
        lhs.intValue == rhs.intValue
    }
}

extension ProtoKeyWrapper: Hashable {

}

extension ProtoKeyWrapper: Comparable {

    static func < (lhs: ProtoKeyWrapper, rhs: ProtoKeyWrapper) -> Bool {
        guard let l = lhs.intValue, let r = rhs.intValue else {
            return lhs.stringValue < rhs.stringValue
        }
        return l < r
    }
}
