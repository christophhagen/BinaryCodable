import Foundation

/**
 An encoder to convert `Codable` objects to binary data.
 */
public final class BinaryEncoder {

    public var sortKeysDuringEncoding: Bool {
        set {
            if newValue {
                userInfo[EncodingOption.sortKeys] = true
            } else {
                userInfo[EncodingOption.sortKeys] = nil
            }
        }
        get {
            userInfo[EncodingOption.sortKeys] as? Bool ?? false
        }
    }
    
    private var userInfo = [CodingUserInfoKey : Any]()
    
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
        let root = EncodingNode(codingPath: [], userInfo: userInfo)
        try value.encode(to: root)
        if root.isNil {
            return Data()
        } else {
            return root.data
        }
    }
    
    func printTree<T>(_ value: T) throws where T: Encodable {
        let root = EncodingNode(codingPath: [], userInfo: userInfo)
        try value.encode(to: root)
        print(root)
    }
    
}
