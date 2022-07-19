import Foundation

/**
 An error produced while decoding binary data.
 */
public enum ProtobufDecodingError: Error {

    case unexpectedDictionaryKey

    /**
     Protocol buffers don't support inheritance, so `super` can't be encoded.
     */
    case superNotSupported

    /**
     The encoded type contains a basic type that is not supported.

     The associated value contains a textual description of the unsupported type.
     */
    case unsupportedType(String)

    /**
     A decoding feature was accessed which is not supported for protobuf encoding.

     The associated value contains a textual description of the invalid access.
     */
    case invalidAccess(String)

}

extension ProtobufDecodingError {
    
    static func unsupported<T>(type t: T.Type) -> ProtobufDecodingError {
        .unsupportedType("\(type(of: t))")
    }
}
