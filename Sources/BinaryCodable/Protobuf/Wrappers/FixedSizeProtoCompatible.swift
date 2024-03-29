import Foundation

/// An integer type which can be forced to use a fixed-length encoding instead of variable-length encoding.
public protocol FixedSizeProtoCompatible: FixedSizeCompatible {

    /// The wire type of the type, which has a constant length
    static var fixedSizeDataType: DataType { get }

    /// The protobuf type equivalent to the fixed size type
    var fixedProtoType: String { get }
}

extension FixedSizeProtoCompatible {

    /// The wire type of the value, which has a constant length
    var fixedSizeDataType: DataType {
        Self.fixedSizeDataType
    }
}
