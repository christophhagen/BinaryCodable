import Foundation

extension UInt16: EncodablePrimitive {
    
    func data() -> Data {
        toData(littleEndian)
    }
    
    static var dataType: DataType {
        .twoBytes
    }
}

extension UInt16: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        self.init(littleEndian: read(data: data, into: UInt16.zero))
    }
}
