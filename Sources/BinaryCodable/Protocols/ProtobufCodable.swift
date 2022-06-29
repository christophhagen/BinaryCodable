import Foundation

typealias ProtobufCodable = ProtobufEncodable & ProtobufDecodable

protocol ProtobufEncodable {

    func protobufData() throws -> Data

    var protoType: String { get }
}

protocol ProtobufDecodable {

    init(fromProtobuf data: Data) throws
}


extension ProtobufEncodable where Self: EncodablePrimitive {

    func protobufData() throws -> Data {
        try data()
    }
}

extension ProtobufDecodable where Self: DecodablePrimitive {

    init(fromProtobuf data: Data) throws {
        try self.init(decodeFrom: data)
    }
}
