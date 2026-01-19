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

extension Sequence {

    func mapAndJoin(_ closure: (Element) throws -> Data) rethrows -> Data {
        var result = Data()
        for (value) in self {
            let data = try closure(value)
            result.append(data)
        }
        return result
    }
}

extension Data {

    /**
     Interpret the binary data as another type.
     - Parameter type: The type to interpret
     */
    func interpreted<T>(as type: T.Type = T.self) -> T {
#if swift(>=6.0)
        withUnsafeBytes { rawBuffer in
            rawBuffer.loadUnaligned(as: T.self)
        }
#else
        precondition(count >= MemoryLayout<T>.size)
        return withUnsafeBytes { rawBuffer in
            rawBuffer.baseAddress!.assumingMemoryBound(to: T.self).pointee
        }
#endif
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
