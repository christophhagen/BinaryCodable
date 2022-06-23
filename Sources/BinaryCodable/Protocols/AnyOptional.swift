import Foundation

protocol AnyOptional {
    
    var isNil: Bool { get }
}

extension Optional: AnyOptional {
    
    var isNil: Bool {
        self == nil
    }
}
