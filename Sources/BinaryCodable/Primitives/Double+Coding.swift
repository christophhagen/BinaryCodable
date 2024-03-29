import Foundation

extension Double: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: bitPattern.bigEndian)
    }
}

extension Double: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw DecodingError.invalidSize(size: data.count, for: "Double", codingPath: codingPath)
        }
        let value = UInt64(bigEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
