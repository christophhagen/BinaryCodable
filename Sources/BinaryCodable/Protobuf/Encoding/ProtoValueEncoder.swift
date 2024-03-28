import Foundation

final class ProtoValueEncoder: AbstractEncodingNode, SingleValueEncodingContainer {

    private var container: EncodingContainer?

    func encodeNil() throws {
        try assign { nil }
    }

    private func assign(_ encoded: () throws -> EncodingContainer?) throws {
        guard container == nil else {
            throw ProtobufEncodingError.multipleValuesInSingleValueContainer
        }
        container = try encoded()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            try assign {
                try wrapError(path: codingPath) {
                    try EncodedPrimitive(protobuf: primitive, excludeDefaults: true)
                }
            }
            return
        }
        try assign {
            try ProtoEncodingNode(path: codingPath, info: userInfo, optional: false).encoding(value)
        }
    }
}

extension ProtoValueEncoder: EncodingContainer {

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
