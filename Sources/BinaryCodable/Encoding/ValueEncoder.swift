import Foundation

final class ValueEncoder: AbstractEncodingNode, SingleValueEncodingContainer {
    
    private var container: EncodingContainer?
    
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
                try EncodedPrimitive(primitive: primitive, protobuf: forceProtobufCompatibility)
            }
            return
        }
        try assign {
            try EncodingNode(codingPath: codingPath, options: options).encoding(value)
        }
    }
}

extension ValueEncoder: EncodingContainer {

    var isNil: Bool { container?.isNil ?? true }
    
    var data: Data {
        container?.data ?? .empty
    }
    
    var dataType: DataType {
        container!.dataType
    }
}
