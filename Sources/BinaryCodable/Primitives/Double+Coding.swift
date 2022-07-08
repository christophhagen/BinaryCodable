import Foundation

extension Double: EncodablePrimitive {
    
    func data() -> Data {
        toData(CFConvertDoubleHostToSwapped(self))
    }
    
    static var dataType: DataType {
        .eightBytes
    }
}

extension Double: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == MemoryLayout<CFSwappedFloat64>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        let value = read(data: data, into: CFSwappedFloat64())
        self = CFConvertDoubleSwappedToHost(value)
    }
}

extension Double: ProtobufCodable {

    var protobufData: Data {
        data().swapped
    }

    init(fromProtobuf data: Data) throws {
        try self.init(decodeFrom: data.swapped)
    }

    var protoType: String { "double" }
}
