import Foundation

protocol DecodingDataProvider {

    associatedtype Index
    
    var startIndex: Index { get }
    
    func isAtEnd(at index: Index) -> Bool
    
    func nextByte(at index: inout Index) -> UInt8?
    
    func nextBytes(_ count: Int, at index: inout Index) -> Data?
}


extension DecodingDataProvider {
    
    /**
     Decode an unsigned integer using variable-length encoding starting at a position.
     - Returns: `Nil`, if insufficient data is available
     */
    private func decodeUInt64(at index: inout Index) -> UInt64? {
        guard let start = nextByte(at: &index) else { return nil }
        return decodeUInt64(startByte: start, at: &index)
    }

    /**
     Decode an unsigned integer using variable-length encoding starting at a position.
     */
    private func decodeUInt64(startByte: UInt8, at index: inout Index) -> UInt64? {
        guard startByte & 0x80 > 0 else {
            return UInt64(startByte)
        }

        var result = UInt64(startByte & 0x7F)
        // There are always 7 usable bits per byte, for 8 bytes
        for byteIndex in 1..<8 {
            guard let nextByte = nextByte(at: &index) else { return nil }
            // Insert the last 7 bit of the byte at the end
            result += UInt64(nextByte & 0x7F) << (byteIndex*7)
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                return result
            }
        }

        // The 9th byte has no next-byte bit, so all 8 bits are used
        guard let nextByte = nextByte(at: &index) else { return nil }
        result += UInt64(nextByte) << 56
        return result
    }
    
    func decodeNextDataOrNilElement(at index: inout Index) throws -> Data? {
        guard let first = nextByte(at: &index) else {
            throw CorruptedDataError.prematureEndofData
        }

        // Check the nil indicator bit
        guard first & 0x01 == 0 else {
            return nil
        }
        // The rest is the length, encoded as a varint
        guard let rawLengthValue = decodeUInt64(startByte: first, at: &index) else {
            throw CorruptedDataError.prematureEndofData
        }

        // Remove the nil indicator bit
        let length = Int(rawLengthValue >> 1)
        guard let element = nextBytes(length, at: &index) else {
            throw CorruptedDataError.prematureEndofData
        }
        return element
    }

    func decodeUnkeyedElements() throws -> [Data?] {
        var elements = [Data?]()
        var index = startIndex
        while !isAtEnd(at: index) {
            let element = try decodeNextDataOrNilElement(at: &index)
            elements.append(element)
        }
        return elements
    }

    private func decodeNextKey(at index: inout Index) throws -> DecodingKey {
        // First, decode the next key
        guard let rawKeyOrLength = decodeUInt64(at: &index) else {
            throw CorruptedDataError.prematureEndofData
        }
        let lengthOrKey = Int(rawKeyOrLength >> 1)

        guard rawKeyOrLength & 1 == 1 else {
            // Int key
            return .integer(lengthOrKey)
        }

        // String key, decode length bytes
        guard let stringData = nextBytes(lengthOrKey, at: &index) else {
            throw CorruptedDataError.prematureEndofData
        }
        let stringKey = try String(data: stringData)
        return .string(stringKey)
    }

    func decodeKeyDataPairs() throws -> [DecodingKey : Data?] {
        var elements = [DecodingKey : Data?]()
        var index = startIndex
        while !isAtEnd(at: index) {
            let key = try decodeNextKey(at: &index)
            guard !isAtEnd(at: index) else {
                throw CorruptedDataError.prematureEndofData
            }
            let element = try decodeNextDataOrNilElement(at: &index)
            guard elements[key] == nil else {
                throw CorruptedDataError("Found multiple values for key \(key)")
            }
            elements[key] = element
        }
        return elements
    }
}
