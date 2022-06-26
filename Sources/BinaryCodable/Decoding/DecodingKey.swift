import Foundation

enum DecodingKey {
    case intKey(Int)
    case stringKey(String)


    func isEqual(to key: CodingKey) -> Bool {
        switch self {
        case .intKey(let value):
            return value == key.intValue
        case .stringKey(let value):
            return value == key.stringValue
        }
    }
}

extension DecodingKey: Equatable {
    
}

extension DecodingKey: Hashable {

}
