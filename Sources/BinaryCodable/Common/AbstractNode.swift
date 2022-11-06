import Foundation

/// Contextual information set by the user for encoding or decoding
typealias UserInfo = [CodingUserInfoKey : Any]

/**
 A node in the encoding and decoding hierarchy.

 Each node in the tree built during encoding and decoding inherits from this type,
 which just provides the basic properties of key path and the custom user info dictionary.

 Child classes: `AbstractEncodingNode` and `AbstractDecodingNode`
 */
class AbstractNode {

    /**
     The path of coding keys taken to get to this point in encoding or decoding.
     */
    let codingPath: [CodingKey]

    /**
     Any contextual information set by the user for encoding or decoding.

     Contains also keys for any custom options set for the encoder and decoder. See `CodingOption`.
     */
    let userInfo: UserInfo


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
    var prependNilIndexSetForUnkeyedContainers: Bool {
        userInfo.has(.prependNilIndicesForUnkeyedContainers)
    }

    /**
     Create an abstract node.
     - Parameter path: The path to get to this point in encoding or decoding
     - Parameter info: Contextual information set by the user
     */
    init(path: [CodingKey], info: UserInfo) {
        self.codingPath = path
        self.userInfo = info
    }
}
