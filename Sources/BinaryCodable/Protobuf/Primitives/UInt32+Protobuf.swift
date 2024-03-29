import Foundation

extension UInt32: ProtobufEncodable {

    func protobufData() -> Data {
        UInt64(self).protobufData()
    }

    var protoType: String { "uint32" }
}

extension UInt32: ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        let intValue = try UInt64.init(fromProtobuf: data, path: path)
        guard let value = UInt32(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }
}
