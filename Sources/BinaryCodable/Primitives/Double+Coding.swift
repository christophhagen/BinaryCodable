import Foundation

extension Double: EncodablePrimitive {
    
    func data() -> Data {
        toData(bitPattern.bigEndian)
    }
    
    static var dataType: DataType {
        .eightBytes
    }
}

extension Double: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt64>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        let value = UInt64(bigEndian: read(data: data, into: UInt64.zero))
        self.init(bitPattern: value)
    }
}
