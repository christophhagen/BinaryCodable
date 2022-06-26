import Foundation

class AbstractEncodingNode {

    let codingPath: [CodingKey]

    let userInfo: [CodingUserInfoKey : Any]

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }

    var sortKeysDuringEncoding: Bool {
        userInfo[EncodingOption.sortKeys] as? Bool ?? false
    }
}
