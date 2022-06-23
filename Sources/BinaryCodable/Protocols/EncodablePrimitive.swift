import Foundation

protocol EncodablePrimitive {
    
    func data() throws -> Data
    
    static var dataType: DataType { get }
}

extension EncodablePrimitive {
    
    var dataType: DataType {
        Self.dataType
    }
}
