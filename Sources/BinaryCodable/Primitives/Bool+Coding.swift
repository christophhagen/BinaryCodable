import Foundation

extension Bool: EncodablePrimitive {
    
    static var dataType: DataType {
        .byte
    }
    
    func data() -> Data {
        Data([self ? 1 : 0])
    }
}

extension Bool: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == 1 else {
            throw BinaryDecodingError.invalidDataSize
        }
        self = data[data.startIndex] > 0
    }
}

extension Bool: ProtobufCodable {
    
    var protoType: String { "bool" }

    static var zero: Bool { false }
}
