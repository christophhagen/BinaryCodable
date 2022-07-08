import Foundation

/**
 An error thrown when encoding a value using `BinaryEncoder`.
 */
public enum BinaryEncodingError: Error {

    /**
     A string could not be encoded to `UTF-8`.

     The associated value of the error is the failed string.

     The string can either be a string key (e.g. a property or enum case name), or a `String` value.
     */
    case stringEncodingFailed(String)

    /**
     Attempted to encode a data type not compatible with Google's Protocol Buffers.

     The associated value of the error is a textual description of the unsupported feature.
     */
    case notProtobufCompatible(String)

    case invalidEncoding(String)
}

extension BinaryEncodingError {

    static var nilValuesNotSupported: BinaryEncodingError {
        .notProtobufCompatible("Nil values are not supported")
    }

    static func unsupportedType<T>(_ value: T) -> BinaryEncodingError {
        .notProtobufCompatible("\(type(of: value)) values are not supported")
    }

    static var superNotSupported: BinaryEncodingError {
        .notProtobufCompatible("Encoding super is not supported")
    }
}
