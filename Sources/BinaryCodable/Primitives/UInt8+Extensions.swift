import Foundation

extension UInt8: EncodablePrimitive {
    
    func data() throws -> Data {
        Data([self])
    }
    
    static var dataType: DataType {
        .byte
    }
}
