import Foundation

extension Int8: EncodablePrimitive {

    var encodedData: Data {
        Data([UInt8(bitPattern: self)])
    }
}

extension Int8: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard data.count == 1 else {
            throw DecodingError.invalidSize(size: data.count, for: "Int8", codingPath: codingPath)
        }
        self.init(bitPattern: data[data.startIndex])
    }
}
