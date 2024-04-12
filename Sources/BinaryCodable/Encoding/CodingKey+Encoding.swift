import Foundation

extension CodingKey {

    /**
     Returns the encoded data for the key.
     - Returns: The encoded data, or `nil`, if the integer coding key is invalid.
     */
    func keyData() -> Data? {
        // String or Int key bit
        // Length of String key or Int key as varint
        // String Key Data
        guard let intValue else {
            let stringData = stringValue.data(using: .utf8)!
            // Set String bit to 1
            let lengthValue = (UInt64(stringData.count) << 1) + 0x01
            let lengthData = lengthValue.variableLengthEncoding
            return lengthData + stringData
        }
        guard intValue >= 0 else {
            return nil
        }
        // For integer keys:
        // The LSB is set to 0
        // Encode 2 * intValue
        return intValue.lengthData
    }
}
