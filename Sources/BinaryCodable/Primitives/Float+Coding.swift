import Foundation

extension Float: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: bitPattern.bigEndian)
    }
}

extension Float: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw DecodingError.invalidSize(size: data.count, for: "Float", codingPath: codingPath)
        }
        let value = UInt32(bigEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

