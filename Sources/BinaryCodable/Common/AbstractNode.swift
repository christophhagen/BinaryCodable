import Foundation

typealias UserInfo = [CodingUserInfoKey : Any]

class AbstractNode {

    let codingPath: [CodingKey]

    let userInfo: UserInfo

    init(path: [CodingKey], info: UserInfo) {
        self.codingPath = path
        self.userInfo = info
    }
}
