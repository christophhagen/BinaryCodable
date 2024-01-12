import Foundation

protocol AnyOptional {

    var isNil: Bool { get }

    static var nilValue: Self { get }
}

extension Optional: AnyOptional {

    var isNil: Bool {
        switch self {
        case .none:
            return true
        default:
            return false
        }
    }

    static var nilValue: Self {
        return Self.none
    }

}
