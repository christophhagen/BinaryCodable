import Foundation

extension Int16: EncodablePrimitive {
    
    func data() -> Data {
        toData(UInt16(bitPattern: self).littleEndian)
    }
    
    static var dataType: DataType {
        .twoBytes
    }
}

extension Int16: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        let value = UInt16(littleEndian: read(data: data, into: UInt16.zero))
        self.init(bitPattern: value)
    }
}
