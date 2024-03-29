import Foundation

extension UInt16: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: littleEndian)
    }
}

extension UInt16: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw DecodingError.invalidSize(size: data.count, for: "UInt16", codingPath: codingPath)
        }
        self.init(littleEndian: data.interpreted())
    }
}
