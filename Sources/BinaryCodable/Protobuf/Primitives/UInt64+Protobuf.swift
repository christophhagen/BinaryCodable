import Foundation

extension UInt64: ProtobufEncodable {

    func protobufData() -> Data {
        variableLengthEncoding
    }

    var protoType: String { "uint64" }
}

extension UInt64: ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(fromVarint: data, path: path)
    }
}
