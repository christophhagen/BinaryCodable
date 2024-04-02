import Foundation

/**
 A wrapper for a coding key to use as a dictionary key
 */
struct HashableKey {

    let key: CodingKey
}

extension HashableKey: Equatable {

    static func == (lhs: HashableKey, rhs: HashableKey) -> Bool {
        lhs.key.stringValue == rhs.key.stringValue
    }
}

extension HashableKey: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(key.stringValue)
    }
}

extension HashableKey: Comparable {

    static func < (lhs: HashableKey, rhs: HashableKey) -> Bool {
        guard let lhsInt = lhs.key.intValue,
              let rhsInt = rhs.key.intValue else {
            return lhs.key.stringValue < rhs.key.stringValue
        }
        return lhsInt < rhsInt
    }
}
