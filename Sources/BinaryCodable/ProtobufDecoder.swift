import Foundation

/**
 An encoder to convert protobuf binary data back to `Codable` objects.

 Decoding unsupported data types causes `BinaryDecodingError.notProtobufCompatible` errors.

 To decode from data, instantiate a decoder and specify the type:
 ```
 let decoder = BinaryDecoder()
 let message = try decoder.decode(Message.self, from: data)
 ```
 Alternatively, the type can be inferred from context:
 ```
 func decode(data: Data) throws -> Message {
     try BinaryDecoder().decode(from: data)
 }
 ```
 There are also convenience functions to directly decode a single instance:
 ```
 let message = try BinaryDecoder.decode(Message.self, from: data)
 ```
 - Note: A single decoder can be used to decode multiple messages.
 */
public final class ProtobufDecoder {

    public var userInfo = [CodingUserInfoKey : Any]()

    /**
     Create a new binary encoder.
     - Note: A single decoder can be used to decode multiple messages.
     */
    public init() {

    }

    /**
     Decode a type from binary data.
     - Parameter type: The type to decode.
     - Parameter data: The binary data which encodes the instance
     - Returns: The decoded instance
     - Throws: Errors of type `BinaryDecodingError` or `ProtobufDecodingError`
     */
    public func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        let root = ProtoDecodingNode(data: data, top: true, path: [], info: userInfo)
        return try type.init(from: root)
    }

    /**
     Decode a single value from binary data using a default decoder.
     - Parameter type: The type to decode.
     - Parameter data: The binary data which encodes the instance
     - Returns: The decoded instance
     - Throws: Errors of type `BinaryDecodingError` or `ProtobufDecodingError`
     */
    public static func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        try ProtobufDecoder().decode(type, from: data)
    }
}
