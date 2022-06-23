import Foundation

extension Bool: EncodablePrimitive {
    
    static var dataType: DataType {
        .byte
    }
    
    func data() -> Data {
        Data([self ? 1 : 0])
    }
}
