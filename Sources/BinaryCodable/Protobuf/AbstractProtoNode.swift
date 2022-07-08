import Foundation

class AbstractProtoNode {

    let codingPath: [CodingKey]

    let userInfo: [CodingUserInfoKey : Any]

    let encodedType: String

    var incompatibilityReason: String?

    var isRoot: Bool {
        codingPath.isEmpty
    }

    init(encoding encodedType: String, path: [CodingKey], info: [CodingUserInfoKey : Any]) {
        self.encodedType = encodedType
        self.codingPath = path
        self.userInfo = info
    }
}
