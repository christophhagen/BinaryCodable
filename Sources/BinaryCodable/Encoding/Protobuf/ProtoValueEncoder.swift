import Foundation

final class ProtoValueEncoder: AbstractEncodingNode, SingleValueEncodingContainer {

    private var container: NonNilEncodingContainer?

    func encodeNil() throws {
        try assign { nil }
    }

    private func assign(_ encoded: () throws -> NonNilEncodingContainer?) throws {
        guard container == nil else {
            throw BinaryEncodingError.multipleValuesInSingleValueContainer
        }
        container = try encoded()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            try assign {
                try EncodedPrimitive(protobuf: primitive)
            }
            return
        }
        try assign {
            try ProtoEncodingNode(path: codingPath, info: userInfo).encoding(value)
        }
    }
}

extension ProtoValueEncoder: NonNilEncodingContainer {

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
