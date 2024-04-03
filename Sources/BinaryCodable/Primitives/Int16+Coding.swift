import Foundation

extension Int16: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: UInt16(bitPattern: self).littleEndian)
    }
}

extension Int16: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int16")
        }
        let value = UInt16(littleEndian: data.interpreted())
        self.init(bitPattern: value)
    }
}
