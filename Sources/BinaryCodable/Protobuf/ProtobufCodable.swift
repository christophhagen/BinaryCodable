import Foundation

typealias ProtobufCodable = ProtobufEncodable & ProtobufDecodable

protocol ProtobufEncodable {

    func protobufData() throws -> Data

    var protoType: String { get }

    var isZero: Bool { get }
}

protocol ProtobufDecodable {

    init(fromProtobuf data: Data, path: [CodingKey]) throws

    static var zero: Self { get }

}

extension ProtobufEncodable where Self: Equatable, Self: ProtobufDecodable {

    var isZero: Bool { self == .zero }
}


extension ProtobufEncodable where Self: EncodablePrimitive {

    func protobufData() throws -> Data {
        try data()
    }
}

extension ProtobufDecodable where Self: DecodablePrimitive {

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        try self.init(decodeFrom: data, path: path)
    }
}
