import Foundation

extension UInt64: EncodablePrimitive {
    
    func data() -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension UInt64: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        self = try UInt64.readVariableLengthEncoded(from: data)
    }
}

extension UInt64: VariableLengthCodable {
    
    /**
     Encode a 64 bit unsigned integer using variable-length encoding.
     
     The first bit in each byte is used to indicate that another byte will follow it.
     So values from 0 to 2^7 - 1 (i.e. 127) will be encoded in a single byte.
     In general, `n` bytes are needed to encode values from ` 2^(n-1) ` to ` 2^n - 1`
     The maximum encodable value ` 2^64 - 1 ` is encoded as 9 byte.
     
     - Parameter value: The value to encode.
     - Returns: The value encoded as binary data (1 to 9 byte)
     */
    var variableLengthEncoding: Data {
        var result = Data()
        var value = self
        // Iterate over the first 56 bit
        for _ in 0..<8 {
            // Extract 7 bit from value
            let nextByte = UInt8(value & 0x7F)
            value = value >> 7
            guard value > 0 else {
                result.append(nextByte)
                return result
            }
            // Set 8th bit to indicate another byte
            result.append(nextByte | 0x80)
        }
        // Add last byte if needed, no next byte indicator necessary
        if value > 0 {
            result.append(UInt8(value))
        }
        return result
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> UInt64 {
        var result: UInt64 = 0
        
        // There are always 7 usable bits per byte, for 8 bytes
        for byteIndex in 0..<8 {
            guard data.startIndex + byteIndex < data.endIndex else {
                throw BinaryDecodingError.prematureEndOfData
            }
            let nextByte = UInt64(data[data.startIndex + byteIndex])
            // Insert the last 7 bit of the byte at the end
            result += UInt64(nextByte & 0x7F) << (byteIndex*7)
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                return result
            }
        }
        guard data.startIndex + 8 < data.endIndex else {
            throw BinaryDecodingError.prematureEndOfData
        }
        // The 9th byte has no next-byte bit, so all 8 bits are used
        let nextByte = UInt64(data[data.startIndex + 8])
        result += UInt64(nextByte) << 56
        return result
    }
}

extension UInt64: HostIndependentRepresentable {

    /// The little-endian representation
    var hostIndependentRepresentation: UInt64 {
        CFSwapInt64HostToLittle(self)
    }

    /**
     Create an `UInt64` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt64) {
        self = CFSwapInt64LittleToHost(value)
    }
}
