import Foundation

extension UInt8: EncodablePrimitive {
    
    func data() -> Data {
        Data([self])
    }
    
    static var dataType: DataType {
        .byte
    }
}

extension UInt8: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == 1 else {
            throw BinaryDecodingError.invalidDataSize
        }
        self = data[data.startIndex]
    }
}
