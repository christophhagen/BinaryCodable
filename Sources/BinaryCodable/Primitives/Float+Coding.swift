import Foundation

extension Float: EncodablePrimitive {

    func data() -> Data {
        toData(bitPattern.bigEndian)
    }
    
    static var dataType: DataType {
        .fourBytes
    }
}

extension Float: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        guard data.count == MemoryLayout<UInt32>.size else {
            throw DecodingError.invalidDataSize(path)
        }
        let value = UInt32(bigEndian: read(data: data, into: UInt32.zero))
        self.init(bitPattern: value)
    }
}
