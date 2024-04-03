import Foundation

extension UInt16: EncodablePrimitive {

    var encodedData: Data {
        .init(underlying: littleEndian)
    }
}

extension UInt16: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt16")
        }
        self.init(littleEndian: data.interpreted())
    }
}
