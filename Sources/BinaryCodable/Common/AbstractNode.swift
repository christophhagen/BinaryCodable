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
     Create an abstract node.
     - Parameter codingPath: The path to get to this point in encoding or decoding
     - Parameter userInfo: Contextual information set by the user
     */
    init(codingPath: [CodingKey], userInfo: UserInfo) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

}
