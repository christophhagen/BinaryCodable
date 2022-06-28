import Foundation

protocol AnyOptional {
    
    var isNil: Bool { get }

    static var nilValue: Self { get }
}

extension Optional: AnyOptional {
    
    var isNil: Bool {
        self == nil
    }

    static var nilValue: Self { nil }
}
