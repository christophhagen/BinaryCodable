import Foundation

public typealias FixedSizeCodable = FixedSizeEncodable & FixedSizeDecodable

/// An integer type which can be forced to use a fixed-length encoding instead of variable-length encoding.
public protocol FixedSizeEncodable: Encodable {

    /// The value encoded as fixed size binary data
    var fixedSizeEncoded: Data { get }
}

public protocol FixedSizeDecodable: Decodable {

    /**
     Decode the value from binary data.
     - Parameter data: The binary data of the correct size for the type.
     - Throws: `DecodingError`
     */
    init(fromFixedSize data: Data, codingPath: [CodingKey]) throws
}
