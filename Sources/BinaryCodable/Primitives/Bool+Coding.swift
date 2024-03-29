import Foundation

extension Bool: EncodablePrimitive {

    var encodedData: Data {
        Data([self ? 1 : 0])
    }
}

extension Bool: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard data.count == 1 else {
            throw DecodingError.invalidSize(size: data.count, for: "Bool", codingPath: codingPath)
        }
        let byte = data[data.startIndex]
        switch byte {
        case 0:
            self = false
        case 1:
            self = true
        default:
            throw DecodingError.corrupted("Found value \(byte) while decoding boolean", codingPath: codingPath)
        }
        self = data[data.startIndex] > 0
    }
}
