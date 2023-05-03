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

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard data.count == 1 else {
            throw DecodingError.invalidDataSize(path)
        }
        self = data[data.startIndex]
    }
}
