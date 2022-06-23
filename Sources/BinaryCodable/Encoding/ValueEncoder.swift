import Foundation

final class ValueEncoder: SingleValueEncodingContainer {
    
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    private var container: EncodingContainer?
    
    init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    func encodeNil() throws {
        assign { nil }
    }
    
    private func assign(_ encoded: () throws -> EncodingContainer?) rethrows {
        guard container == nil else {
            fatalError("Multiple values encoded in single value container")
        }
        container = try encoded()
    }
    
    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            try assign {
                try EncodedPrimitive(primitive: primitive)
            }
            return
        }
        try assign {
            try EncodingNode(codingPath: codingPath, userInfo: userInfo).encoding(value)
        }
    }
}

extension ValueEncoder: EncodingContainer {
    
    var data: Data {
        container?.data ?? Data()
    }
    
    var dataType: DataType {
        container?.dataType ?? .noValue
    }
}

extension ValueEncoder: CustomStringConvertible {
    
    var description: String {
        guard let container = container else {
            return "Value (nil)"
        }
        return "Value\n" + "\(container)".indented()
        
    }
}
