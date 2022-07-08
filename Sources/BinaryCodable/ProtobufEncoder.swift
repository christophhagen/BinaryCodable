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

    private var options: Set<CodingOption> {
        []
    }

    /**
     Create a new binary encoder.
     - Note: An ecoder can be used to encode multiple messages.
     */
    public init() {

    }

    /**
     Encode a value to binary data.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `BinaryEncodingError`
     */
    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        let root = ProtoEncodingNode(codingPath: [], options: options)
        try value.encode(to: root)
        return root.data
    }

    public func getProtobufDefinition<T>(_ value: T) throws -> String where T: Encodable {
        let root = try ProtoNode(encoding: "\(type(of: value))", path: [], info: [:])
            .encoding(value)
        return try "syntax = \"proto3\";\n\n" + root.protobufDefinition()
    }
}
