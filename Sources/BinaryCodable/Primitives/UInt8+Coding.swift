import Foundation

extension UInt8: EncodablePrimitive {

    var encodedData: Data {
        Data([self])
    }
}

extension UInt8: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard data.count == 1 else {
            throw DecodingError.invalidSize(size: data.count, for: "UInt8", codingPath: codingPath)
        }
        self = data[data.startIndex]
    }
}
