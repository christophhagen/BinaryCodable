import Foundation

struct ProtoPrimitive: ProtoContainer {
    
    let protoTypeName: String

    init(primitive: ProtobufEncodable) throws {
        self.protoTypeName = primitive.protoType
    }

    func protobufDefinition() throws -> String {
        ""
    }
}
