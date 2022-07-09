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
     A procedural error occuring during encoding.

     A custom implementation of `func encode(to encoder: Encoder) throws` tried to encode multiple values into a single value container:

     ```
     func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        container.encode(...)
        container.encode(...) // Invalid
     }
     ```
     */
    case multipleValuesInSingleValueContainer
}

extension BinaryEncodingError: Equatable {
    
}
