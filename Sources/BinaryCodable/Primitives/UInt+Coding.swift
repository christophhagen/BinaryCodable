import Foundation

extension UInt: EncodablePrimitive {
    
    func data() -> Data {
        variableLengthEncoding
    }
    
    static var dataType: DataType {
        .variableLengthInteger
    }
}

extension UInt: DecodablePrimitive {

    init(decodeFrom data: Data, path: [CodingKey]) throws {
        try self.init(fromVarint: data, path: path)
    }
}

extension UInt: FixedSizeCompatible {

    static public var fixedSizeDataType: DataType {
        .eightBytes
    }

    public var fixedProtoType: String {
        "fixed64"
    }

    public init(fromFixedSize data: Data, path: [CodingKey]) throws {
        let intValue = try UInt64(fromFixedSize: data, path: path)
        guard let value = UInt(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }

    public var fixedSizeEncoded: Data {
        UInt64(self).fixedSizeEncoded
    }
}

extension UInt: VariableLengthCodable {
    
    var variableLengthEncoding: Data {
        UInt64(self).variableLengthEncoding
    }
    
    init(fromVarint data: Data, path: [CodingKey]) throws {
        let intValue = try UInt64(fromVarint: data, path: path)
        guard let value = UInt(exactly: intValue) else {
            throw DecodingError.variableLengthEncodedIntegerOutOfRange(path)
        }
        self = value
    }
}
