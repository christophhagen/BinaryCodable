import Foundation

class AbstractEncodingNode: AbstractNode {

    var sortKeysDuringEncoding: Bool {
        userInfo[EncodingOption.sortKeys] as? Bool ?? false
    }
}
