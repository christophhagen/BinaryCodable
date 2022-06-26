import Foundation

class AbstractNode {

    let codingPath: [CodingKey]

    let userInfo: [CodingUserInfoKey : Any]

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
}
