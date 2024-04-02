import Foundation

/**
 A protocol adopted by primitive types for encoding.
 */
protocol EncodableContainer {

    /// Indicate if the container needs to have a length prepended
    var needsLengthData: Bool { get }

    /// Indicate if the container can encode nil
    var needsNilIndicator: Bool { get }

    /// Indicate if the container encodes nil
    /// - Note: This property must not be `true` if `needsNilIndicator` is set to `false`
    var isNil: Bool { get }

    /**
     Provide the data encoded in the container
     - Note: No length information must be included
     - Note: This function is only called if `isNil` is false
     */
    func containedData() throws -> Data
}

extension EncodableContainer {

    /**

     */
    func completeData(with key: CodingKey, codingPath: [CodingKey]) throws -> Data {
        try key.keyData(codingPath: codingPath) + completeData()
    }

    /**
     The full data encoded in the container, including nil indicator and length, if needed
     */
    func completeData() throws -> Data {
        guard !isNil else {
            // A nil value always means:
            // - That the length is zero
            // - That a nil indicator is needed
            return Data([0x01])
        }
        let data = try containedData()
        if needsLengthData {
            // It doesn't matter if `needsNilIndicator` is true or false
            // Length always includes it
            return data.count.lengthData + data
        }
        if needsNilIndicator {
            return Data([0x00]) + data
        }
        return data
    }
}

private extension Int {

    /// Encodes the integer as the length of a nil/length indicator
    var lengthData: Data {
        // The first bit (LSB) is the `nil` bit (0)
        // The rest is the length, encoded as a varint
        (UInt64(self) << 1).encodedData
    }
}

private extension CodingKey {

    func keyData(codingPath: [CodingKey]) throws -> Data {
        // String or Int key bit
        // Length of String key or Int key as varint
        // String Key Data
        guard let intValue else {
            let stringData = stringValue.data(using: .utf8)!
            // Set String bit to 1
            let lengthValue = (UInt64(stringData.count) << 1) + 0x01
            let lengthData = lengthValue.encodedData
            return lengthData + stringData
        }
        guard intValue >= 0 else {
            throw EncodingError.invalidValue(intValue, .init(codingPath: codingPath + [self], debugDescription: "Invalid integer value for coding key"))
        }
        // For integer keys:
        // The LSB is set to 0
        // Encode 2 * intValue
        return intValue.lengthData
    }
}
