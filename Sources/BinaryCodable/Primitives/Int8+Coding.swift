import Foundation

extension Int8: EncodablePrimitive {

    var encodedData: Data {
        Data([UInt8(bitPattern: self)])
    }
}

extension Int8: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == 1 else {
            throw CorruptedDataError(invalidSize: data.count, for: "Int8")
        }
        self.init(bitPattern: data[data.startIndex])
    }
}
