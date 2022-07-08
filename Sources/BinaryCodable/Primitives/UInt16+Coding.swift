import Foundation

extension UInt16: EncodablePrimitive {
    
    func data() -> Data {
        toData(CFSwapInt16HostToLittle(self))
    }
    
    static var dataType: DataType {
        .twoBytes
    }
}

extension UInt16: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        guard data.count == MemoryLayout<UInt16>.size else {
            throw BinaryDecodingError.invalidDataSize
        }
        self = read(data: data, into: UInt16.zero)
    }
}
