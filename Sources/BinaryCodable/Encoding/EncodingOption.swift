import Foundation

enum CodingOption: String {

    case sortKeys = "sort"

    var infoKey: CodingUserInfoKey {
        .init(rawValue: rawValue)!
    }
}
