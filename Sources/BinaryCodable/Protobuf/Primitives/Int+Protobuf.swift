import Foundation

extension Int: ProtobufEncodable {

    func protobufData() -> Data {
        variableLengthEncoding
    }

    var protoType: String { "sint64" }
}

extension Int: ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(fromVarint: data, path: path)
    }
}
