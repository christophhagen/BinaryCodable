import Foundation

protocol EncodablePrimitive: DataTypeProvider {
    
    func data() throws -> Data
}
