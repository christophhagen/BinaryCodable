import Foundation

extension UInt16: EncodablePrimitive {
    
    func data() throws -> Data {
        hostIndependentBinaryData
    }
    
    static var dataType: DataType {
        .twoBytes
    }
}

extension UInt16: HostIndependentRepresentable {

    /// The little-endian representation
    var hostIndependentRepresentation: UInt16 {
        CFSwapInt16HostToLittle(self)
    }

    /**
     Create an `UInt16` value from its host-independent (little endian) representation.
     - Parameter value: The host-independent representation
     */
    init(fromHostIndependentRepresentation value: UInt16) {
        self = CFSwapInt16LittleToHost(value)
    }
}
