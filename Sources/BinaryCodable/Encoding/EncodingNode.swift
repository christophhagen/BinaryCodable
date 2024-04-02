import Foundation

final class EncodingNode: AbstractEncodingNode, Encoder {

    private var hasMultipleCalls = false

    private var encodedValue: EncodableContainer? = nil

    private func assign<T>(_ value: T) -> T where T: EncodableContainer {
        // Prevent multiple calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()
        if encodedValue == nil {
            encodedValue = value
        } else {
            hasMultipleCalls = true
        }
        return value
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        return KeyedEncodingContainer(assign(KeyedEncoder<Key>(needsLengthData: needsLengthData, codingPath: codingPath, userInfo: userInfo)))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        return assign(UnkeyedEncoder(needsLengthData: needsLengthData, codingPath: codingPath, userInfo: userInfo))
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return assign(ValueEncoder(codingPath: codingPath, userInfo: userInfo))
    }
}

extension EncodingNode: EncodableContainer {

    var needsNilIndicator: Bool {
        // If no value is encoded, then it doesn't matter what is returned, `encodedData()` will throw an error
        encodedValue?.needsNilIndicator ?? false
    }

    var isNil: Bool {
        // Returning false for missing encodedValue forces an error on `encodedData()`
        encodedValue?.isNil ?? false
    }

    func containedData() throws -> Data {
        guard !hasMultipleCalls else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "Multiple calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
        }
        guard let encodedValue else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "No calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
        }
        let data = try encodedValue.containedData()
        return data
    }
}
