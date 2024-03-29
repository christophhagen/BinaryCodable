import Foundation

extension Bool: EncodablePrimitive {
    
    static var dataType: DataType {
        .variableLengthInteger
    }
    
    func data() -> Data {
        Data([self ? 1 : 0])
    }
}

extension Bool: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard data.count == 1 else {
            throw DecodingError.invalidDataSize(path)
        }
        self = data[data.startIndex] > 0
    }
}
