import Foundation

class AbstractEncodingNode: AbstractNode {

    /**
     Sort keyed data in the binary representation.

     Enabling this option causes all keyed data (e.g. `Dictionary`, `Struct`) to be sorted by their keys before encoding.
     This enables deterministic encoding where the binary output is consistent across multiple invocations.

     Enabling this option introduces computational overhead due to sorting, which can become significant when dealing with many entries.

     This option has no impact on decoding using `BinaryDecoder`.

     - Note: The default value for this option is `false`.
     */
    var sortKeysDuringEncoding: Bool {
        userInfo.has(.sortKeys)
    }
    
    var containsOptional: Bool

    init(path: [CodingKey], info: UserInfo, optional: Bool) {
        self.containsOptional = optional
        super.init(path: path, info: info)
    }
}
