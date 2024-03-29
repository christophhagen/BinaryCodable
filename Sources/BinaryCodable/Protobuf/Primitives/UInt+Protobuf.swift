import Foundation

extension UInt: ProtobufEncodable {

    func protobufData() -> Data {
        variableLengthEncoding
    }

    var protoType: String { "uint64" }
}

extension UInt: ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(fromVarint: data, path: path)
    }

}
