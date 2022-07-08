import Foundation

extension Float: EncodablePrimitive {

    func data() -> Data {
        toData(CFConvertFloatHostToSwapped(self))
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
        let value = read(data: data, into: CFSwappedFloat32())
        self = CFConvertFloatSwappedToHost(value)
    }
}

extension Float: ProtobufCodable {

    var protobufData: Data {
        data().swapped
    }

    init(fromProtobuf data: Data) throws {
        try self.init(decodeFrom: data.swapped)
    }

    var protoType: String { "float" }
}
