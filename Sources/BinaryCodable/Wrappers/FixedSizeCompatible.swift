import Foundation

/// An integer type which can be forced to use a fixed-length encoding instead of variable-length encoding.
public protocol FixedSizeCompatible {

    /// The wire type of the type, which has a constant length
    static var fixedSizeDataType: DataType { get }

    /// The protobuf type equivalent to the fixed size type
    var fixedProtoType: String { get }

    /// The value encoded as fixed size binary data
    var fixedSizeEncoded: Data { get }

    /**
     Decode the value from binary data.
     - Parameter data: The binary data of the correct size for the type.
     - Throws: `DecodingError`
     */
    init(fromFixedSize data: Data, path: [CodingKey]) throws
}

extension FixedSizeCompatible {

    /// The wire type of the value, which has a constant length
    var fixedSizeDataType: DataType {
        Self.fixedSizeDataType
    }
}
