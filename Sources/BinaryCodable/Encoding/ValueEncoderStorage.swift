import Foundation

/**
 The backing storage for single value containers.

 Encodes a single value.
 It can be set multiple times, but only the last value is used.
 */
final class ValueEncoderStorage: AbstractEncodingNode {

    private var encodedValue: EncodableContainer?

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        super.init(needsLengthData: false, codingPath: codingPath, userInfo: userInfo)
    }

    func encodeNil() throws {
        // Note: An already encoded value will simply be replaced
        // This is consistent with the implementation of JSONEncoder()
        encodedValue = NilContainer()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        // Note: An already encoded value will simply be replaced
        // This is consistent with the implementation of JSONEncoder()
        self.encodedValue = try encodeValue(value, needsLengthData: false)
    }
}

extension ValueEncoderStorage: EncodableContainer {

    var needsNilIndicator: Bool { true }

    var isNil: Bool {
        encodedValue is NilContainer
    }

    func containedData() throws -> Data {
        guard let encodedValue else {
            // TODO: Provide value of outer encoding node in error
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "No value or nil encoded in single value container"))
        }
        let data = try encodedValue.completeData()
        return data
    }
}
