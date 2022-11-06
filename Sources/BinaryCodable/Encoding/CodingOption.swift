import Foundation

enum CodingOption: String {

    case sortKeys = "sort"

    case prependNilIndicesForUnkeyedContainers = "nilIndices"

    var infoKey: CodingUserInfoKey {
        .init(rawValue: rawValue)!
    }
}

extension UserInfo {

    func has(_ option: CodingOption) -> Bool {
        (self[option.infoKey] as? Bool) == true
    }
}
