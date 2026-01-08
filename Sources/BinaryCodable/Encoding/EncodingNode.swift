import Foundation

@_spi(internals) public
final class EncodingNode: AbstractEncodingNode, Encoder {

    private var encodedValue: EncodableContainer? = nil

    @_spi(internals) public
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        guard let encodedValue else {
            let storage = KeyedEncoderStorage(needsLengthData: needsLengthData, codingPath: codingPath, userInfo: userInfo)
            self.encodedValue = storage
            return KeyedEncodingContainer(KeyedEncoder(storage: storage))
        }
        guard let storage = encodedValue as? KeyedEncoderStorage else {
            fatalError("Call to container(keyedBy:) after already calling unkeyedContainer() or singleValueContainer()")
        }
        return KeyedEncodingContainer(KeyedEncoder(storage: storage))
    }

    @_spi(internals) public
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        guard let encodedValue else {
            let storage = UnkeyedEncoderStorage(needsLengthData: needsLengthData, codingPath: codingPath, userInfo: userInfo)
            self.encodedValue = storage
            return UnkeyedEncoder(storage: storage)
        }
        guard let storage = encodedValue as? UnkeyedEncoderStorage else {
            fatalError("Call to unkeyedContainer() after already calling container(keyedBy:) or singleValueContainer()")
        }
        return UnkeyedEncoder(storage: storage)
    }

    @_spi(internals) public
    func singleValueContainer() -> SingleValueEncodingContainer {
        guard let encodedValue else {
            // No previous container generated, create the storage
            // and return a wrapper to it
            let storage = ValueEncoderStorage(codingPath: codingPath, userInfo: userInfo)
            self.encodedValue = storage
            return ValueEncoder(storage: storage)
        }
        guard let storage = encodedValue as? ValueEncoderStorage else {
            fatalError("Call to singleValueContainer() after already calling unkeyedContainer() or container(keyedBy:)")
        }
        // Multiple calls to singleValueContainer()
        // Return a wrapper with the same underlying storage
        // The last value encoded to any of the wrappers will be used
        return ValueEncoder(storage: storage)
    }
}

extension EncodingNode: EncodableContainer {

    @_spi(internals) public
    var needsNilIndicator: Bool {
        // If no value is encoded, then it doesn't matter what is returned, `encodedData()` will throw an error
        encodedValue?.needsNilIndicator ?? false
    }

    @_spi(internals) public
    var isNil: Bool {
        // Returning false for missing encodedValue forces an error on `encodedData()`
        encodedValue?.isNil ?? false
    }

    @_spi(internals) public
    func containedData() throws -> Data {
        guard let encodedValue else {
            throw EncodingError.invalidValue(0, .init(codingPath: codingPath, debugDescription: "No calls to container(keyedBy:), unkeyedContainer(), or singleValueContainer()"))
        }
        let data = try encodedValue.containedData()
        return data
    }
}
