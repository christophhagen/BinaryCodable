import Foundation

struct EncodedPrimitive: EncodingContainer {
    
    let dataType: DataType

    let data: Data
    
    let description: String
    
    init(primitive: EncodablePrimitive) throws {
        self.dataType = primitive.dataType
        self.data = try primitive.data()
        self.description = "\(type(of: primitive)) (\(primitive))"
    }
}

extension EncodedPrimitive: CustomStringConvertible { }
