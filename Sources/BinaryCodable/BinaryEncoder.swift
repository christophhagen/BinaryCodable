import Foundation

/**
 An encoder to convert `Codable` objects to binary data.
 */
public final class BinaryEncoder {
    
    private let root = EncodingNode()
    
    /**
     Create a new binary encoder.
     */
    public init() {
        
    }
    
    /**
     Encode a value to binary data.
     - Parameter value: The value to encode
     - Returns: The encoded data
     - Throws: Errors of type `BinaryEncodingError`
     */
    public func encode<T>(_ value: T) throws -> Data where T: Encodable {
        defer { root.reset() }
        try value.encode(to: root)
        return root.data
    }
    
    func printTree<T>(_ value: T) throws where T: Encodable {
        defer { root.reset() }
        try value.encode(to: root)
        print(root)
    }
    
}
