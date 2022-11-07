import Foundation

protocol AnyOptional {

    var isNil: Bool { get }
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

}
