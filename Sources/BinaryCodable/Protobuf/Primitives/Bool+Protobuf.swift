import Foundation

extension Bool: ProtobufCodable {

    var protoType: String { "bool" }

    static var zero: Bool { false }
}
