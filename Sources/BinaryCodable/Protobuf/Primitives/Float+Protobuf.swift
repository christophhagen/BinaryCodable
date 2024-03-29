import Foundation

extension Float: ProtobufCodable {

    func protobufData() throws -> Data {
        data().swapped
    }

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(decodeFrom: data.swapped, path: path)
    }

    var protoType: String { "float" }
}
