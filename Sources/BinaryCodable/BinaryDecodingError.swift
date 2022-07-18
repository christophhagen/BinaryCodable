import Foundation

/**
 An error produced while decoding binary data.
 */
public enum BinaryDecodingError: Error {

    /**
     The data for a primitive type did not have the right size.
     - Note: This error is internal and should not occur in practice.
     */
    case invalidDataSize

    /**
     The binary data is missing for a key.

     The associated value is the `CodingKey` not found in the data.
     */
    case missingDataForKey(CodingKey)

    /**
     The binary data contained an unknown data type.

     The associated value is the unknown raw value of the data type.
     */
    case unknownDataType(Int)

    /**
     The binary data ended before all values were decoded.
     */
    case prematureEndOfData

    /**
     A `String` contained in the data could not be decoded.

     The failing string can be either a value, or a string key (e.g. a property name or enum case).
     */
    case invalidString

    /**
     An integer encoded in the binary data as a varint does not fit into the specified integer type, producing an overflow.
     */
    case variableLengthEncodedIntegerOutOfRange

    /**
     The binary data contains multiple values for a key.
     */
    case multipleValuesForKey
    
    /**
     An indication that the data is corrupted or otherwise invalid.
     
     As an associated value, this case contains the context for debugging.
     
     This error can occur when an unknown enum value was decoded.
     - Note: This error case mirrors `DecodingError.dataCorrupted()`
     */
    case dataCorrupted(DecodingError.Context)
    
    /**
     An indication that a value of the given type could not be decoded because it did not match the type of what was found in the encoded payload.
     
     As associated values, this case contains the attempted type and context for debugging.
     - Note: This error case mirrors `DecodingError.typeMismatch()`
     */
    case typeMismatch(Any.Type, DecodingError.Context)
    
    /**
     An indication that a non-optional value of the given type was expected, but a null value was found.
     
     - Note: This error case mirrors `DecodingError.valueNotFound()`
     */
    case valueNotFound(Any.Type, DecodingError.Context)
    
    /**
     An unexpected and unknown error occured during decoding.
     
     As the associated value, this case contains the original error.
     */
    case unknownError(Error)
}

extension BinaryDecodingError {
    
    /**
     Internal initializer to convert decoding errors to binary decoding errors.
     - Parameter error: The error to wrap.
     */
    init(_ error: DecodingError) {
        switch error {
        case .dataCorrupted(let context):
            self = .dataCorrupted(context)
        case .typeMismatch(let type, let context):
            self = .typeMismatch(type, context)
        case .valueNotFound(let type, let context):
            self = .valueNotFound(type, context)
        case .keyNotFound(let key, _):
            self = .missingDataForKey(key)
        @unknown default:
            self = .unknownError(error)
        }
    }
    
    /**
     Internal initializer to convert errors to binary decoding errors.
     - Parameter error: The error to wrap.
     */
    init(wrapping error: Error) {
        switch error {
        case let error as DecodingError:
            self.init(error)
        case let error as BinaryDecodingError:
            self = error
        default:
            self = .unknownError(error)
        }
    }
}
