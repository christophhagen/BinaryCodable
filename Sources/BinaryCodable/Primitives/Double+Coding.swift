import Foundation

extension Double: EncodablePrimitive {
    
    func data() -> Data {
        toData(bitPattern.bigEndian)
    }
    
    static var dataType: DataType {
        .eightBytes
    }
}

extension Double: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        let value = UInt64(bigEndian: read(data: data, into: UInt64.zero))
        self.init(bitPattern: value)
    }
}

extension Double: ProtobufEncodable {

    func protobufData() throws -> Data {
        data().swapped
    }

    var protoType: String { "double" }
}

extension Double: ProtobufDecodable {

    init(fromProtobuf data: Data) throws {
        try self.init(decodeFrom: data.swapped)
    }
}
