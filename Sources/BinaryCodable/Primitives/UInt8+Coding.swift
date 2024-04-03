import Foundation

extension UInt8: EncodablePrimitive {

    var encodedData: Data {
        Data([self])
    }
}

extension UInt8: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == 1 else {
            throw CorruptedDataError(invalidSize: data.count, for: "UInt8")
        }
        self = data[data.startIndex]
    }
}
