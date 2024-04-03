import Foundation

/**
 A class to provide decoding functions to all decoding containers.
 */
class AbstractDecodingNode: AbstractNode {

    let parentDecodedNil: Bool

    init(parentDecodedNil: Bool, codingPath: [CodingKey], userInfo: UserInfo) {
        self.parentDecodedNil = parentDecodedNil
        super.init(codingPath: codingPath, userInfo: userInfo)
    }
}

extension AbstractDecodingNode: AbstractDecoder {
    
}
