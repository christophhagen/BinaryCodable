import Foundation

protocol DecodingDataProvider: AnyObject {

    var codingPath: [CodingKey] { get }

    var isAtEnd: Bool { get }

    func nextByte() throws -> UInt64

    var numberOfRemainingBytes: Int { get }

    func getBytes(_ count: Int) throws -> Data
}

extension DecodingDataProvider {

    func remainingBytes() throws -> Data {
        try getBytes(numberOfRemainingBytes)
    }

    /**
     Decode an unsigned integer using variable-length encoding starting at a position.
     */
    func decodeUInt64() throws -> UInt64 {
        let start = try nextByte()
        return try decodeUInt64(startByte: start)
    }

    /**
     Decode an unsigned integer using variable-length encoding starting at a position.
     */
    private func decodeUInt64(startByte: UInt64) throws -> UInt64 {
        guard startByte & 0x80 > 0 else {
            return startByte
        }

        var result = startByte & 0x7F
        // There are always 7 usable bits per byte, for 8 bytes
        for byteIndex in 1..<8 {
            let nextByte = try nextByte()
            // Insert the last 7 bit of the byte at the end
            result += UInt64(nextByte & 0x7F) << (byteIndex*7)
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                return result
            }
        }

        // The 9th byte has no next-byte bit, so all 8 bits are used
        let nextByte = try nextByte()
        result += UInt64(nextByte) << 56
        return result
    }

    private func decodeNilIndicatorOrLength() throws -> Int? {
        let first = try nextByte()

        // Check the nil indicator bit
        guard first & 0x01 == 0 else {
            return nil
        }
        // The rest is the length, encoded as a varint
        let rawLengthValue = try decodeUInt64(startByte: first)

        // Remove the nil indicator bit
        return Int(rawLengthValue >> 1)
    }

    func decodeNextDataOrNilElement() throws -> Data? {
        guard let length = try decodeNilIndicatorOrLength() else {
            return nil
        }
        return try getBytes(length)
    }

    func decodeUnkeyedElements() throws -> [Data?] {
        var elements = [Data?]()
        while !isAtEnd {
            let element = try decodeNextDataOrNilElement()
            elements.append(element)
        }
        return elements
    }

    func decodeNextKey() throws -> DecodingKey {
        // First, decode the next key
        let rawKeyOrLength = try decodeUInt64()
        let lengthOrKey = Int(rawKeyOrLength >> 1)

        guard rawKeyOrLength & 1 == 1 else {
            // Int key
            return .integer(lengthOrKey)
        }

        // String key, decode length bytes
        let stringData = try getBytes(lengthOrKey)
        let stringKey = try String(data: stringData, codingPath: codingPath)
        return .string(stringKey)
    }

    func decodeKeyDataPairs() throws -> [DecodingKey : Data?] {
        var elements = [DecodingKey : Data?]()
        while !isAtEnd {
            let key = try decodeNextKey()
            guard !isAtEnd else {
                throw corrupted("Unexpected end of data after decoding key")
            }
            let element = try decodeNextDataOrNilElement()
            guard elements[key] == nil else {
                throw corrupted("Found multiple values for key \(key)")
            }
            elements[key] = element
        }
        return elements
    }


    /**
     Decode just the nil indicator byte, but don't extract a length. Uses all remaining bytes for the value.
     - Note: This function is only used for the root node
     */
    func decodeSingleElementWithNilIndicator() throws -> Data? {
        let first = try nextByte()
        // Check the nil indicator bit
        switch first {
        case 0:
            return try remainingBytes()
        case 1:
            guard isAtEnd else {
                throw corrupted("\(numberOfRemainingBytes) additional bytes found after nil indicator")
            }
            return nil
        default:
            throw corrupted("Found unexpected nil indicator \(first)")
        }
    }

    /**
     Check if the value is `nil` or return the wrapped data.
     - Note: This function is the equivalent to `encodedDataWithNilIndicatorAndLength()`.
     */
    func decodingSingleElementWithNilIndicatorAndLength() throws -> Data? {
        let first = try nextByte()
        // Check the nil indicator bit
        guard first & 0x01 == 0 else {
            return nil
        }
        // The rest is the length, encoded as a varint
        let rawLengthValue = try decodeUInt64()
        // Remove the nil indicator bit
        let length = Int(rawLengthValue >> 1)
        let wrappedElement = try getBytes(length)
        guard isAtEnd else {
            throw corrupted("Found \(numberOfRemainingBytes) unexpected bytes after encoded data")
        }
        return wrappedElement
    }

    func corrupted(_ message: String) -> DecodingError {
        return .corrupted(message, codingPath: codingPath)
    }
}
