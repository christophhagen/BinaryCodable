import Foundation

/**
 An encoder to convert `Codable` objects to protobuf binary data.

 The encoder provides only limited compatibility with Google's Protocol Buffers.

 Encoding unsupported data types causes `BinaryEncodingError.notProtobufCompatible` errors.

 Construct an encoder when converting instances to binary data, and feed the message(s) into it:

 ```swift
 let message: Message = ...

 let encoder = ProtobufEncoder()
 let data = try encoder.encode(message)
 ```

 - Note: An ecoder can be used to encode multiple messages.
 */
public final class ProtobufEncoder {

    /**
     Any contextual information set by the user for encoding.

     This dictionary is passed to all containers during the encoding process.

     Contains also keys for any custom options set for the encoder.
     See `sortKeysDuringEncoding`.
     */
    public var userInfo = [CodingUserInfoKey : Any]()

    /**
     Create a new binary encoder.
     - Note: An encoder can be used to encode multiple messages.
     */
    public init() {

    }

    /**
     Encode a value to binary data.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `BinaryEncodingError` or `ProtobufEncodingError`
     */
    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let root = ProtoEncodingNode(path: [], info: userInfo, optional: false)
        try value.encode(to: root)
        return root.data
    }

    /**
     Encode a single value to binary data using a default encoder.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `BinaryEncodingError` or `ProtobufEncodingError`
     */
    public static func encode<T>(_ value: T) throws -> Data where T: Encodable {
        try ProtobufEncoder().encode(value)
    }

    func getProtobufDefinition<T>(_ value: T) throws -> String where T: Encodable {
        let root = try ProtoNode(encoding: "\(type(of: value))", path: [], info: userInfo)
            .encoding(value)
        return try "syntax = \"proto3\";\n\n" + root.protobufDefinition()
    }
}
