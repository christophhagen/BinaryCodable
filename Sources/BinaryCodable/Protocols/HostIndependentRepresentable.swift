import Foundation

/**
 A protocol adopted by primitive types which can be converted to a platform-independent binary representation.
 
 In order to provide full protocol conformance, the following must be true for all values:
 ```swift
 let converted = value.hostIndependentRepresentation
 value == .init(fromHostIndependentRepresentation: converted) // true
 ```

 The host-independent representation is in little-endian format,
 in order to be compatible with the [Protocol Buffers:  Encoding](https://developers.google.com/protocol-buffers/docs/encoding#non-varint_numbers)
 */
protocol HostIndependentRepresentable {

    /// The type storing the platform-independent representation
    associatedtype IndependentType
    
    /// The value converted to a platform-independent format
    var hostIndependentRepresentation: IndependentType { get }
    
    /**
     Create a value from a platform-independent representation.
     
     - Parameter value: The host-independent representation to convert into a value.
     */
    init(fromHostIndependentRepresentation value: IndependentType)
    
    static var empty: IndependentType { get }
}

extension HostIndependentRepresentable where IndependentType: AdditiveArithmetic {
    
    static var empty: IndependentType { .zero }
}

extension HostIndependentRepresentable {
    
    /// Convert a value to host-independent binary data.
    var hostIndependentBinaryData: Data {
        toData(hostIndependentRepresentation)
    }
    
    static var binaryDataSize: Int {
        MemoryLayout<IndependentType>.size
    }

    init(hostIndependentBinaryData data: Data) throws {
        guard data.count == Self.binaryDataSize else {
            throw BinaryDecodingError.invalidDataSize
        }
        let value = read(data: data, into: Self.empty)
        self.init(fromHostIndependentRepresentation: value)
    }
    
}

func read<T>(data: Data, into value: T) -> T {
    data.withUnsafeBytes {
        $0.baseAddress!.load(as: T.self)
    }
}

func toData<T>(_ value: T) -> Data {
    var target = value
    return withUnsafeBytes(of: &target) {
        Data($0)
    }
}
