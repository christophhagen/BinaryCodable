import Foundation

extension Bool: EncodablePrimitive {

    var encodedData: Data {
        Data([self ? 1 : 0])
    }
}

extension Bool: DecodablePrimitive {

    init(data: Data) throws {
        guard data.count == 1 else {
            throw CorruptedDataError(invalidSize: data.count, for: "Bool")
        }
        let byte = data[data.startIndex]
        switch byte {
        case 0:
            self = false
        case 1:
            self = true
        default:
            throw CorruptedDataError("Found value \(byte) while decoding boolean")
        }
        self = data[data.startIndex] > 0
    }
}
