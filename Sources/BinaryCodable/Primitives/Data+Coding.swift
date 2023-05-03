import Foundation

extension Data: EncodablePrimitive {

    static var dataType: DataType {
        .variableLength
    }

    func data() -> Data {
        self
    }
}

extension Data: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) {
        self = Data(data)
    }
}

extension Data: ProtobufCodable {

    var protoType: String { "bytes" }

    static var zero: Data { .empty }
}
