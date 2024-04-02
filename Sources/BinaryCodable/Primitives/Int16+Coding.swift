import Foundation

extension Int16: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: UInt16(bitPattern: self).littleEndian)
    }
}

extension Int16: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw DecodingError.invalidSize(size: data.count, for: "Int16", codingPath: codingPath)
        }
        let value = UInt16(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
