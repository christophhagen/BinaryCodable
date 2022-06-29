import Foundation

enum CodingOption: String {

    case sortKeys = "sort"

    case protobufCompatibility = "proto"

    var infoKey: CodingUserInfoKey {
        .init(rawValue: rawValue)!
    }
}
