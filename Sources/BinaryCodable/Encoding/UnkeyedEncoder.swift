import Foundation

final class UnkeyedEncoder: UnkeyedEncodingContainer {
    
    var codingPath: [CodingKey]
    
    var userInfo: [CodingUserInfoKey : Any]
    
    var count: Int = 0
    
    var content = [EncodingContainer]()
    
    init(codingPath: [CodingKey] = [], userInfo: [CodingUserInfoKey : Any] = [:]) {
        self.codingPath = codingPath
        self.userInfo = userInfo
    }
    
    @discardableResult
    private func assign<T>(_ encoded: () throws -> T) rethrows -> T where T: EncodingContainer {
        let value = try encoded()
        content.append(value)
        return value
    }
    
    func encodeNil() throws {
        #warning("How to wrap optionals?")
    }
    
    /*
    func encode(_ value: Bool) throws {
        
    }
    
    func encode(_ value: String) throws {
        
    }
    
    func encode(_ value: Double) throws {
        
    }
    
    func encode(_ value: Float) throws {
        
    }
    
    func encode(_ value: Int) throws {
        
    }
    
    func encode(_ value: Int8) throws {
        
    }
    
    func encode(_ value: Int16) throws {
        
    }
    
    func encode(_ value: Int32) throws {
        
    }
    
    func encode(_ value: Int64) throws {
        
    }
    
    func encode(_ value: UInt) throws {
        
    }
    
    func encode(_ value: UInt8) throws {
        
    }
    
    func encode(_ value: UInt16) throws {
        
    }
    
    func encode(_ value: UInt32) throws {
        
    }
    
    func encode(_ value: UInt64) throws {
        
    }
     */
    /*
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Bool {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == String {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Double {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Float {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Int {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Int8 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Int16 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Int32 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == Int64 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == UInt {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == UInt8 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == UInt16 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == UInt32 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element == UInt64 {
        
    }
    
    func encode<T>(contentsOf sequence: T) throws where T : Sequence, T.Element : Encodable {
        
    }
    */
    func encode<T>(_ value: T) throws where T : Encodable {
        if let primitive = value as? EncodablePrimitive {
            try assign {
                try EncodedPrimitive(primitive: primitive)
            }
            return
        }
        try assign {
            try EncodingNode(codingPath: codingPath, userInfo: userInfo).encoding(value)
        }
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = assign {
            KeyedEncoder<NestedKey>(codingPath: codingPath, userInfo: userInfo)
        }
        return KeyedEncodingContainer(container)
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        assign {
            UnkeyedEncoder(codingPath: codingPath, userInfo: userInfo)
        }
    }
    
    #warning("Signal super encoder")
    func superEncoder() -> Encoder {
        assign {
            EncodingNode(codingPath: codingPath, userInfo: userInfo)
        }
    }
}

extension UnkeyedEncoder: EncodingContainer {
    
    var data: Data {
        content.reduce(Data()) { result, container in
            if container.dataType == .variableLength {
                let data = container.data
                let count = data.count.variableLengthEncoding
                return result + count + data
            }
            return result + container.data
        }
    }
    
    var dataType: DataType {
        .variableLength
    }
}
