import Foundation

extension Int64: ProtobufEncodable {

    func protobufData() -> Data {
        variableLengthEncoding
    }

    var protoType: String { "sint64" }
}

extension Int64: ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(fromVarint: data, path: path)
    }

}
