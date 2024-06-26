import Foundation

/**
 A type that can be encoded and decoded as a fixed-size value.
 */
public typealias FixedSizeCodable = FixedSizeEncodable & FixedSizeDecodable

/// An integer type which can be forced to use a fixed-length encoding instead of variable-length encoding.
public protocol FixedSizeEncodable: Encodable {

    /// The value encoded as fixed size binary data
    var fixedSizeEncoded: Data { get }
}

/**
 A type that can be encoded with a fixed number of bytes.
 */
public protocol FixedSizeDecodable: Decodable {

    /**
     Decode the value from binary data.
     - Parameter data: The binary data of the correct size for the type.
     - Throws: ``CorruptedDataError``
     */
    init(fromFixedSize data: Data) throws
}

extension FixedSizeDecodable {

    /// The number of bytes needed for a fixed-size encoding
    static var fixedEncodedByteCount: Int { MemoryLayout<Self>.size }
}
