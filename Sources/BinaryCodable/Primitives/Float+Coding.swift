import Foundation

extension Float: EncodablePrimitive {

    func data() -> Data {
        toData(bitPattern.bigEndian)
    }
    
    static var dataType: DataType {
        .fourBytes
    }
}

extension Float: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == MemoryLayout<CFSwappedFloat32>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        let value = UInt32(bigEndian: read(data: data, into: UInt32.zero))
        self.init(bitPattern: value)
    }
}

extension Float: ProtobufCodable {

    func protobufData() throws -> Data {
        data().swapped
    }

    init(fromProtobuf data: Data) throws {
        try self.init(decodeFrom: data.swapped)
    }

    var protoType: String { "float" }
}
