import Foundation

/**
 A decoder to convert data encoded with `BinaryEncoder` back to a `Codable` types.

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
 - Note: A single decoder can be used to decode multiple objects.
 */
public struct BinaryDecoder {

    /**
     Any contextual information set by the user for decoding.

     This dictionary is passed to all containers during the decoding process.
     */
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    /**
     Create a new decoder.
     - Note: A single decoder can be reused to decode multiple objects.
     */
    public init() {

    }

    /**
     Decode a type from binary data.
     - Parameter type: The type to decode.
     - Parameter data: The binary data which encodes the instance
     - Returns: The decoded instance
     - Throws: Errors of type `DecodingError`
     */
    public func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        // Directly decode primitives, otherwise it would be decoded with a nil indicator
        if let BaseType = T.self as? DecodablePrimitive.Type {
            do {
                return try BaseType.init(data: data) as! T
            } catch let error as CorruptedDataError {
                throw error.adding(codingPath: [])
            }
        }
        let node = try DecodingNode(data: data, parentDecodedNil: false, codingPath: [], userInfo: userInfo)
        return try T.init(from: node)
    }

    /**
     Decode a single value from binary data using a default decoder.
     - Parameter type: The type to decode.
     - Parameter data: The binary data which encodes the instance
     - Returns: The decoded instance
     - Throws: Errors of type `DecodingError`
     */
    public static func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        try BinaryDecoder().decode(type, from: data)
    }
}
