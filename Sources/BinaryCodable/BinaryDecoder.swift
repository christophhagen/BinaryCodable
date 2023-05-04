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
     Assumes that unkeyed containers are encoded using a set of indices for `nil` values.

     Refer to the ``prependNilIndexSetForUnkeyedContainers`` property of ``BinaryEncoder``
     for more information about the binary data format in both cases.

     - Note: This option defaults to `false`
     - Note: To decode successfully, the encoder must use the same setting for `prependNilIndexSetForUnkeyedContainers`.
     */
    public var containsNilIndexSetForUnkeyedContainers: Bool = false

    /**
     The info for decoding.

     Combines the info data provided by the user with the internal keys of the decoding options.
     */
    private var fullInfo: [CodingUserInfoKey : Any] {
        var info = userInfo
        if containsNilIndexSetForUnkeyedContainers {
            info[CodingOption.prependNilIndicesForUnkeyedContainers.infoKey] = true
        }
        return info
    }

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
     - Throws: Errors of type `DecodingError`
     */
    public func decode<T>(_ type: T.Type = T.self, from data: Data) throws -> T where T: Decodable {
        let root = DecodingNode(data: data, path: [], info: fullInfo)
        return try type.init(from: root)
    }

    /**
     Decode a type from a data stream.

     This function is the pendant to `encodeForStream()` on ``BinaryEncoder``, and decodes a type from a data stream.
     The additional length information added to the stream is used to correctly decode each element.
     - Note: This function is not exposed publicly to keep the API easy to understand.
     Advanced features like stream decoding are handled by ``BinaryStreamDecoder``.
     */
    func decode<T>(_ type: T.Type = T.self, fromStream provider: BinaryStreamProvider) throws -> T where T: Decodable {
        let root = DecodingNode(decoder: provider, path: [], info: fullInfo)
        return try type.init(from: root)
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
