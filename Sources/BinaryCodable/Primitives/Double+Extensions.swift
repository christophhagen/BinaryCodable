import Foundation

extension Double: EncodablePrimitive {
    
    func data() -> Data {
        hostIndependentBinaryData.swapped
    }
    
    static var dataType: DataType {
        .eightBytes
    }
}

extension Double: DecodablePrimitive {

    init(decodeFrom data: Data) throws {
        try self.init(hostIndependentBinaryData: data.swapped)
    }
}

extension Double: HostIndependentRepresentable {

    /// The double converted to little-endian
    var hostIndependentRepresentation: CFSwappedFloat64 {
        CFConvertDoubleHostToSwapped(self)
    }

    /**
     Create a double from a little-endian float64.
     - Parameter value: The host-independent representation.
     */
    init(fromHostIndependentRepresentation value: CFSwappedFloat64) {
        self = CFConvertDoubleSwappedToHost(value)
    }

    /// Create an empty host-indepentent float64
    static var empty: CFSwappedFloat64 { .init() }
}

