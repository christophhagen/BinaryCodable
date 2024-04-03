import Foundation

extension Double: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: bitPattern.bigEndian)
    }
}

extension Double: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Double")
        }
        let value = UInt64(bigEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
