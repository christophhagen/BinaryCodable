import Foundation

extension Int32: EncodablePrimitive {
    
    func data() -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension Int32: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        try self.init(fromZigZag: data)
    }
}

extension Int32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt32(bitPattern: self).variableLengthEncoding
    }
    
    init(fromVarint data: Data) throws {
        let value = try UInt32(fromVarint: data)
        self = Int32(bitPattern: value)
    }
}

extension Int32: HostIndependentRepresentable {

    /**
     Convert the value to a host-independent (little endian) format.
     */
    var hostIndependentRepresentation: UInt32 {
        CFSwapInt32HostToLittle(.init(bitPattern: self))
    }

    /**
     Create an `Int32` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt32) {
        self.init(bitPattern: CFSwapInt32LittleToHost(value))
    }
}

extension Int32: ZigZagCodable {

    /**
     Encode a 64 bit signed integer using variable-length encoding.

     The sign of the value is extracted and appended as an additional bit.
     Positive signed values are thus encoded as `UInt(value) * 2`, and negative values as `UInt(abs(value) * 2 + 1`

     - Parameter value: The value to encode.
     - Returns: The value encoded as binary data (1 to 9 byte)
     */
    var zigZagEncoded: Data {
        Int64(self).zigZagEncoded
    }

    init(fromZigZag data: Data) throws {
        let raw = try Int64(fromZigZag: data)
        guard let value = Int32(exactly: raw) else {
            throw BinaryDecodingError.variableLengthEncodedIntegerOutOfRange
        }
        self = value
    }
}

