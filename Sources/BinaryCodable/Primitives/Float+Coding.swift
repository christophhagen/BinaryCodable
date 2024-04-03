import Foundation

extension Float: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: bitPattern.bigEndian)
    }
}

extension Float: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Float")
        }
        let value = UInt32(bigEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}

