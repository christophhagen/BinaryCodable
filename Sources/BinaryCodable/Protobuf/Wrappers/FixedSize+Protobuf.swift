import Foundation

extension FixedSize: ProtobufEncodable where WrappedValue: ProtobufDecodable {

    func protobufData() throws -> Data {
        wrappedValue.fixedSizeEncoded
    }

    var protoType: String {
        wrappedValue.fixedProtoType
    }
}

extension FixedSize: ProtobufDecodable where WrappedValue: ProtobufDecodable {

    static var zero: FixedSize {
        .init(wrappedValue: .zero)
    }

    init(fromProtobuf data: Data, path: [CodingKey]) throws {
        let value = try WrappedValue(fromFixedSize: data, path: path)
        self.init(wrappedValue: value)
    }
}
