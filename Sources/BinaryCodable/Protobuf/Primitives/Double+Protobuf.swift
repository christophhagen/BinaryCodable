import Foundation

extension Double: ProtobufEncodable {

    func protobufData() throws -> Data {
        data().swapped
    }

    var protoType: String { "double" }
}

extension Double: ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(decodeFrom: data.swapped, path: path)
    }
}
