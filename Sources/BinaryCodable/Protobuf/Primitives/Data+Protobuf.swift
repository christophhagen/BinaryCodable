import Foundation

extension Data: ProtobufCodable {

    var protoType: String { "bytes" }

    static var zero: Data { .empty }
}
