import Foundation

extension String: ProtobufCodable {

    var protoType: String { "string" }

    static let zero = ""
}
