import Foundation

extension Int32: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt32(bitPattern: self).variableLengthEncoding
    }
    
    static func readVariableLengthEncoded(from data: Data) throws -> (value: Int32, consumedBytes: Int) {
        let decoded = try UInt32.readVariableLengthEncoded(from: data)
        return (value: Int32(bitPattern: decoded.value), consumedBytes: decoded.consumedBytes)
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
