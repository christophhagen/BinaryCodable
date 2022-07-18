import Foundation

protocol ProtoContainer {

    func protobufDefinition() throws -> String

    var protoTypeName: String { get }
}
