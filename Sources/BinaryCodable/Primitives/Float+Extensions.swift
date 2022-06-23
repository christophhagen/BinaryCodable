import Foundation

extension Float: EncodablePrimitive {

    func data() -> Data {
        hostIndependentBinaryData
    }
    
    static var dataType: DataType {
        .fourBytes
    }
}

extension Float: HostIndependentRepresentable {

    /// The float converted to little-endian
    var hostIndependentRepresentation: CFSwappedFloat32 {
        CFConvertFloatHostToSwapped(self)
    }

    /**
     Create a float from a little-endian float32.
     - Parameter value: The host-independent representation.
     */
    init(fromHostIndependentRepresentation value: CFSwappedFloat32) {
        self = CFConvertFloatSwappedToHost(value)
    }

    /// Create an empty host-indepentent float32
    static var empty: CFSwappedFloat32 { .init() }
}
