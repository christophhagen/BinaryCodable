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
public final class BinaryEncoder {

    /**
     Sort keyed data in the binary representation.

     Enabling this option causes all keyed data (e.g. `Dictionary`, `Struct`) to be sorted by their keys before encoding.
     This option can enable deterministic encoding where the binary output is consistent across multiple invocations.

     - Warning: Output will not be deterministic when using `Set`, or `Dictionary<Key, Value>` where `Key` is not `String` or `Int`.

     Enabling this option introduces computational overhead due to sorting, which can become significant when dealing with many entries.

     This option has no impact on decoding using `BinaryDecoder`.

     Enabling this option will add the `CodingUserInfoKey(rawValue: "sort")` to the `userInfo` dictionary.

     - Note: The default value for this option is `false`.
     */
    public var sortKeysDuringEncoding: Bool = false

    /**
     Add a set of indices for `nil` values in unkeyed containers.

     This option changes the encoding of unkeyed sequences like arrays with optional values.

     If this option is set to `true`, then the encoded binary data first contains a list of indexes for each position where `nil` is encoded.
     After this data the remaining (non-nil) values are added.
     If this option is `false`, then each value is prepended with a byte `1` for non-nil values, and a byte `0` for `nil` values.

     Using an index set is generally more efficient, expect for large sequences with many `nil` values.
     An index set is encoded using first the number of elements, and then each element, all encoded as var-ints.

     - Note: This option defaults to `true`
     - Note: To decode successfully, the decoder must use the same setting for `containsNilIndexSetForUnkeyedContainers`.
     */
    public var prependNilIndexSetForUnkeyedContainers: Bool = true

    /**
     Any contextual information set by the user for encoding.

     This dictionary is passed to all containers during the encoding process.

     Contains also keys for any custom options set for the encoder.
     See `sortKeysDuringEncoding`.
     */
    public var userInfo = [CodingUserInfoKey : Any]()

    /**
     The info for encoding.

     Combines the info data provided by the user with the internal keys of the encoding options.
     */
    private var fullInfo: [CodingUserInfoKey : Any] {
        var info = userInfo
        if sortKeysDuringEncoding {
            info[CodingOption.sortKeys.infoKey] = true
        }
        if prependNilIndexSetForUnkeyedContainers {
            info[CodingOption.prependNilIndicesForUnkeyedContainers.infoKey] = true
        }
        return info
    }
    
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
     - Throws: Errors of type `BinaryEncodingError`
     */
    public func encode(_ value: Encodable) throws -> Data {
        let root = EncodingNode(path: [], info: fullInfo)
        do {
            try value.encode(to: root)
        } catch {
            throw BinaryEncodingError(wrapping: error)
        }
        if root.isNil {
            return Data()
        } else {
            return root.data
        }
    }

    /**
     Encode a single value to binary data using a default encoder.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `BinaryEncodingError`
     */
    public static func encode(_ value: Encodable) throws -> Data {
        try BinaryEncoder().encode(value)
    }
}
