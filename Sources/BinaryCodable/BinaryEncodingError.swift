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
    
    case invalidValue(Any, EncodingError.Context)
    
    case unknownError(Error)
}

extension BinaryEncodingError {
    
    init(_ error: EncodingError) {
        switch error {
        case .invalidValue(let type, let context):
            self = .invalidValue(type, context)
        @unknown default:
            self = .unknownError(error)
        }
    }
    
    init(wrapping error: Error) {
        switch error {
        case let error as EncodingError:
            self.init(error)
        case let error as BinaryEncodingError:
            self = error
        default:
            self = .unknownError(error)
        }
    }
}
