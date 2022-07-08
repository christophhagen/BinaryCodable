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
     This enables deterministic encoding where the binary output is consistent across multiple invocations.

     Enabling this option introduces computational overhead due to sorting, which can become significant when dealing with many entries.

     This option has no impact on decoding using `BinaryDecoder`.

     - Note: The default value for this option is `false`.
     */
    public var sortKeysDuringEncoding: Bool = false

    public var userInfo = [CodingUserInfoKey : Any]()

    private var fullInfo: [CodingUserInfoKey : Any] {
        var info = userInfo
        if sortKeysDuringEncoding {
            info[CodingOption.sortKeys.infoKey] = true
        }
        return info
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
        let root = EncodingNode(path: [], info: userInfo)
        try value.encode(to: root)
        if root.isNil {
            return Data()
        } else {
            return root.data
        }
    }
}
