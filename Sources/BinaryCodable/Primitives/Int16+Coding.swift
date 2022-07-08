import Foundation

extension Int16: EncodablePrimitive {
    
    func data() -> Data {
        toData(CFSwapInt16HostToLittle(.init(bitPattern: self)))
    }
    
    static var dataType: DataType {
        .twoBytes
    }
}

extension Int16: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        let value = read(data: data, into: UInt16.zero)
        self.init(bitPattern: CFSwapInt16LittleToHost(value))
    }
}
