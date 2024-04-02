import Foundation

final class ValueEncoder: AbstractEncodingNode, SingleValueEncodingContainer {

    private var encodedValue: EncodableContainer?

    init(codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        super.init(needsLengthData: false, codingPath: codingPath, userInfo: userInfo)
    }

    func encodeNil() throws {
        guard encodedValue == nil else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "Single value container: Multiple calls to encodeNil() or encode<T>()"))
        }
        encodedValue = NilContainer()
    }

    func encode<T>(_ value: T) throws where T : Encodable {
        guard encodedValue == nil else {
            throw EncodingError.invalidValue(value, .init(codingPath: codingPath, debugDescription: "Single value container: Multiple calls to encodeNil() or encode<T>()"))
        }
        self.encodedValue = try encodeValue(value, needsLengthData: false)
    }
}

extension ValueEncoder: EncodableContainer {

    var needsNilIndicator: Bool { true }

    var isNil: Bool {
        encodedValue is NilContainer
    }

    func containedData() throws -> Data {
        guard let encodedValue else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "No value or nil encoded in single value container"))
        }
        let data = try encodedValue.completeData()
        return data
    }
}
