import Foundation

extension Data {

    /// An empty data instance
    static var empty: Data {
        .init()
    }

    /// The data converted to a byte array
    var bytes: [UInt8] {
        Array(self)
    }

    /// The data in reverse ordering
    var swapped: Data {
        Data(reversed())
    }
}

extension Sequence where Element: Sequence, Element.Element == UInt8 {

    var joinedData: Data {
        Data(joined())
    }
}

extension Data {

    /**
     Interpret the binary data as another type.
     - Parameter type: The type to interpret
     */
    func interpreted<T>(as type: T.Type = T.self) -> T {
        Data(self).withUnsafeBytes {
            $0.baseAddress!.load(as: T.self)
        }
    }

    /**
     Extract the binary representation of a value.
     - Parameter value: The value to convert to binary data
     */
    init<T>(underlying value: T) {
        var target = value
        self = Swift.withUnsafeBytes(of: &target) {
            Data($0)
        }
    }
}

extension Optional<Data> {

    var view: String {
        guard let self else {
            return "nil"
        }
        return "\(Array(self))"
    }
}
