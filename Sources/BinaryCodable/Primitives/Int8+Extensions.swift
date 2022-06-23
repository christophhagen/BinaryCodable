import Foundation

extension Int8: EncodablePrimitive {
    
    func data() throws -> Data {
        try UInt8(bitPattern: self).data()
    }
    
    static var dataType: DataType {
        .byte
    }
}
