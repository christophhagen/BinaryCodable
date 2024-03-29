import Foundation

extension Int32: ProtobufCodable {

    func protobufData() -> Data {
        Int64(self).protobufData()
    }

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        let intValue = try Int64(fromProtobuf: data, path: path)
        guard let value = Int32(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }

    var protoType: String { "sint32" }
}
