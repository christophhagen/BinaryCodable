import Foundation

final class ProtoValueThrowingEncoder: ProtoThrowingNode, SingleValueEncodingContainer {

    func encodeNil() throws {
        throw error
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        throw error
    }
}
