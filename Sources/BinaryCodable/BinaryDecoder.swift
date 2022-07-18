import Foundation

/**
 An encoder to convert binary data back to `Codable` objects.

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
public final class BinaryDecoder {

    /**
     Any contextual information set by the user for decoding.

     This dictionary is passed to all containers during the decoding process.
     */
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
     - Throws: Errors of type `BinaryDecodingError`
     */
    public func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        let root = DecodingNode(data: data, top: true, path: [], info: userInfo)
        do {
            return try type.init(from: root)
        } catch {
            throw BinaryDecodingError(wrapping: error)
        }
    }

    /**
     Decode a single value from binary data using a default decoder.
     - Parameter type: The type to decode.
     - Parameter data: The binary data which encodes the instance
     - Returns: The decoded instance
     - Throws: Errors of type `BinaryDecodingError`
     */
    public static func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        try BinaryDecoder().decode(type, from: data)
    }
}
