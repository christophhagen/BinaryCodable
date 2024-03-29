import Foundation

/**
 An encoder to convert `Codable` objects to binary data.

 Construct an encoder when converting instances to binary data, and feed the message(s) into it:

 ```swift
 let message: Message = ...

 let encoder = BinaryEncoder()
 let data = try encoder.encode(message)
 ```

 - Note: An ecoder can be used to encode multiple messages.
 */
public struct BinaryEncoder {

    /// The user info key for the ``sortKeysInKeyedContainers`` option.
    public static let userInfoSortKey: CodingUserInfoKey = .init(rawValue: "sortByKey")!

    /**
     Sort keyed data in the binary representation.

     Enabling this option causes all data in keyed containers (e.g. `Dictionary`, `Struct`) to be sorted by their keys before encoding.
     This option can enable deterministic encoding where the binary output is consistent across multiple invocations.

     - Warning: Output will not be deterministic when using `Set`, or `Dictionary<Key, Value>` where `Key` is not `String` or `Int`.

     Enabling this option introduces computational overhead due to sorting, which can become significant when dealing with many entries.

     This option has no impact on decoding using `BinaryDecoder`.

     Enabling this option will add the `CodingUserInfoKey(rawValue: "sortByKey")` to the `userInfo` dictionary.
     This key is also available as ``SimpleEncoder.userInfoSortKey``

     - Note: The default value for this option is `false`.
     */
    public var sortKeysDuringEncoding: Bool {
        get {
            userInfo[BinaryEncoder.userInfoSortKey] as? Bool ?? false
        }
        set {
            userInfo[BinaryEncoder.userInfoSortKey] = newValue
        }
    }

    /// Any contextual information set by the user for encoding.
    public var userInfo: [CodingUserInfoKey : Any] = [:]

    /**
     Create a new encoder.
     - Note: An encoder can be used to encode multiple messages.
     */
    public init() {

    }

    /**
     Encode a value to binary data.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `EncodingError`
     */
    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        // Directly encode primitives, otherwise:
        // - Data would be encoded as an unkeyed container
        // - There would always be a nil indicator byte 0x00 at the beginning
        // NOTE: The comparison of the types is necessary, since otherwise optionals are matched as well.
        if T.self is EncodablePrimitive.Type, let value = value as? EncodablePrimitive {
            return value.encodedData
        }
        let encoder = EncodingNode(needsLengthData: false, codingPath: [], userInfo: userInfo)
        try value.encode(to: encoder)
        return try encoder.completeData()
    }

    /**
     Encode a single value to binary data using a default encoder.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `EncodingError`
     */
    public static func encode(_ value: Encodable) throws -> Data {
        try BinaryEncoder().encode(value)
    }

    // MARK: Stream encoding

    /**
     Encodes a value to binary data for use in a data stream.

     This function differs from 'normal'  encoding by the  additional length information prepended to the element..
     This information is used when decoding values from a data stream.

     - Note: This function is not exposed publicly to keep the API easy to understand.
     Advanced features like stream encoding are handled by ``BinaryStreamEncoder``.


     - Parameter value: The value to encode
     - Returns: The encoded data for the element
     - Throws: Errors of type `EncodingError`
     */
    func encodeForStream(_ value: Encodable) throws -> Data {
        let encoder = EncodingNode(needsLengthData: true, codingPath: [], userInfo: userInfo)
        try value.encode(to: encoder)
        return try encoder.completeData()
    }
}
