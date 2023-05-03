import Foundation

extension Int8: EncodablePrimitive {
    
    func data() -> Data {
        Data([UInt8(bitPattern: self)])
    }
    
    static var dataType: DataType {
        .byte
    }
}

extension Int8: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard data.count == 1 else {
            throw DecodingError.invalidDataSize(path)
        }
        self.init(bitPattern: data[data.startIndex])
    }
}
