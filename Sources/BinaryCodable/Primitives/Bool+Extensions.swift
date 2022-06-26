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
        switch data[data.startIndex] {
        case 0:
            self = false
        case 1:
            self = true
        default:
            throw BinaryDecodingError.invalidData
        }
    }
}
