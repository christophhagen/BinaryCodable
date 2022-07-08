import Foundation

final class ValueEncoder: AbstractEncodingNode, SingleValueEncodingContainer {
    
    private var container: EncodingContainer?
    
    func encodeNil() throws {
        try assign { nil }
    }
    
    private func assign(_ encoded: () throws -> EncodingContainer?) throws {
        guard container == nil else {
            throw BinaryEncodingError.multipleValuesInSingleValueContainer
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
            try EncodingNode(path: codingPath, info: userInfo).encoding(value)
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

    var isEmpty: Bool {
        container?.isEmpty ?? true
    }
}
