import Foundation

extension UInt32: EncodablePrimitive {
    
    func data() throws -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension UInt32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> (value: UInt32, consumedBytes: Int) {
        let (intValue, consumedBytes) = try UInt64.readVariableLengthEncoded(from: data)
        guard let value = UInt32(exactly: intValue) else {
            throw BinaryEncodingError.variableLengthEncodedIntegerOutOfRange
        }
        return (value: value, consumedBytes: consumedBytes)
    }
}

extension UInt32: HostIndependentRepresentable {

    /// The little-endian representation
    var hostIndependentRepresentation: UInt32 {
        CFSwapInt32HostToLittle(self)
    }

    /**
     Create an `UInt32` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt32) {
        self = CFSwapInt32LittleToHost(value)
    }
}
