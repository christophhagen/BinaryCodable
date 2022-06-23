import Foundation

extension Int64: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(bitPattern: self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> (value: Int64, consumedBytes: Int) {
        let decoded = try UInt64.readVariableLengthEncoded(from: data)
        return (value: Int64(bitPattern: decoded.value), consumedBytes: decoded.consumedBytes)
    }
}

extension Int64: HostIndependentRepresentable {

    /**
     Convert the value to a host-independent (little endian) format.
     */
    var hostIndependentRepresentation: UInt64 {
        CFSwapInt64HostToLittle(.init(bitPattern: self))
    }

    /**
     Create an `Int64` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt64) {
        self.init(bitPattern: CFSwapInt64LittleToHost(value))
    }
}
