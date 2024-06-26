import Foundation

/**
 A type that can be encoded and decoded as a variable-length integer
 */
public typealias VariableLengthCodable = VariableLengthEncodable & VariableLengthDecodable

/**
 A type that can be encoded as a variable-length integer
 */
public protocol VariableLengthEncodable: FixedWidthInteger, Encodable {

    /// The value encoded as binary data using variable-length integer encoding
    var variableLengthEncoding: Data { get }
}

/**
 A type that can be decoded as a variable-length integer
 */
public protocol VariableLengthDecodable: FixedWidthInteger, Decodable {

    /**
     Decode a value as a variable-length integer.
     - Parameter data: The encoded value
     - Throws: ``CorruptedDataError``
     */
    init(fromVarint raw: UInt64) throws
}
