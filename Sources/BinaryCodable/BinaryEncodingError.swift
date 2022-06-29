import Foundation

/**
 An error thrown when encoding a value using `BinaryEncoder`.
 */
public enum BinaryEncodingError: Error {

    /**
     A string could not be encoded to `UTF-8`.

     The string can either be a string key (e.g. a property or enum case name), or a `String` value.
     */
    case stringEncodingFailed(String)

    /**
     Attempted to encode a data type not compatible with Google's Protocol Buffers.

     This error can only appear when the `forceProtobufCompatibility = true` for the encoder.
     */
    case notProtobufCompatible
}
