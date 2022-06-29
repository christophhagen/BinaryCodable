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
