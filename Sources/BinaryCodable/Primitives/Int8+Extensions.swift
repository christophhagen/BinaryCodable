import Foundation

extension Int8: EncodablePrimitive {
    
    func data() throws -> Data {
        try UInt8(bitPattern: self).data()
    }
    
    static var dataType: DataType {
        .byte
    }
}

extension Int8: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == 1 else {
            throw BinaryDecodingError.invalidDataSize
        }
        self.init(bitPattern: data[data.startIndex])
    }
}
