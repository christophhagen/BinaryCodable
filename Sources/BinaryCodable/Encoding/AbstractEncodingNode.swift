import Foundation

/**
 A class that provides encoding functions for all encoding containers.
 */
@_spi(internals) public
class AbstractEncodingNode: AbstractNode {

    @_spi(internals) public
    let needsLengthData: Bool

    /**
    - Parameter codingPath: The path to get to this point in encoding or decoding
    - Parameter userInfo: Contextual information set by the user
    */
    @_spi(internals) public
    init(needsLengthData: Bool, codingPath: [CodingKey], userInfo: UserInfo) {
        self.needsLengthData = needsLengthData
        super.init(codingPath: codingPath, userInfo: userInfo)
    }

    /**
     Sort keyed data in the binary representation.

     Enabling this option causes all keyed data (e.g. `Dictionary`, `Struct`) to be sorted by their keys before encoding.
     This enables deterministic encoding where the binary output is consistent across multiple invocations.

     Enabling this option introduces computational overhead due to sorting, which can become significant when dealing with many entries.

     This option has no impact on decoding using `BinaryDecoder`.

     - Note: The default value for this option is `false`.
     */
    var sortKeysDuringEncoding: Bool {
        userInfo[BinaryEncoder.userInfoSortKey] as? Bool ?? false
    }

    func encodeValue<T>(_ value: T, needsLengthData: Bool) throws -> EncodableContainer where T : Encodable {
        if T.self is EncodablePrimitive.Type, let base = value as? EncodablePrimitive {
            return PrimitiveEncodingContainer(wrapped: base, needsLengthData: needsLengthData)
        } else {
            let encoder = EncodingNode(needsLengthData: needsLengthData, codingPath: codingPath, userInfo: userInfo)
            try value.encode(to: encoder)
            return encoder
        }
    }
}
