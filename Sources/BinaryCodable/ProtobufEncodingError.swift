import Foundation

/**
 An error thrown when encoding a value using `ProtobufEncoder`.
 */
public enum ProtobufEncodingError: Error {

    case noValueInSingleValueContainer

    /**
     The encoded type contains optional values, which are not supported in the protocol buffer format.
     */
    case nilValuesNotSupported

    /**
     The encoded type contains a basic type that is not supported.

     The associated value contains a textual description of the unsupported type.
     */
    case unsupportedType(String)

    /**
     Protocol buffers don't support inheritance, so `super` can't be encoded.
     */
    case superNotSupported

    /**
     The encoded type contains properties which don't have an integer key.

     The associated value contains the string key which is missing an integer key.
     */
    case missingIntegerKey(String)

    /**
     All values in unkeyed containers must have the same type.
     */
    case multipleTypesInUnkeyedContainer

    /**
     Field numbers must be positive integers not greater than `536870911` (`2^29-1`, or `0x1FFFFFFF`)

     The associated value is the integer key that is out of range.
     */
    case integerKeyOutOfRange(Int)

    /**
     Multiple calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder.
     */
    case multipleContainersAccessed

    /**
     No calls to `container<>(keyedBy:)`, `unkeyedContainer()`, or `singleValueContainer()` for an encoder.
     */
    case noContainersAccessed

    /**
     Protobuf requires an unkeyed container as the root node
     */
    case rootIsNotKeyedContainer

    case protobufDefinitionUnavailable(String)

    static func unsupported(type value: EncodablePrimitive) -> ProtobufEncodingError {
        .unsupportedType("\(type(of: value))")
    }
}
