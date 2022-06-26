import Foundation

extension Int16: EncodablePrimitive {
    
    func data() throws -> Data {
        hostIndependentBinaryData
    }
    
    static var dataType: DataType {
        .twoBytes
    }
}

extension Int16: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        try self.init(hostIndependentBinaryData: data)
    }
}

extension Int16: HostIndependentRepresentable {

    /**
     Convert the value to a host-independent (little endian) format.
     */
    var hostIndependentRepresentation: UInt16 {
        CFSwapInt16HostToLittle(.init(bitPattern: self))
    }

    /**
     Create an `Int16` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt16) {
        self.init(bitPattern: CFSwapInt16LittleToHost(value))
    }
}
