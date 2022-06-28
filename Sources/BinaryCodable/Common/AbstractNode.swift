import Foundation

class AbstractNode {

    let codingPath: [CodingKey]

    let options: Set<CodingOption>

    var userInfo: [CodingUserInfoKey : Any] {
        options.reduce(into: [:]) { $0[$1.infoKey] = true }
    }

    init(codingPath: [CodingKey], options: Set<CodingOption>) {
        self.codingPath = codingPath
        self.options = options
    }
}
