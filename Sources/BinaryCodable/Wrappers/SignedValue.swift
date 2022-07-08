import Foundation

/**
 A wrapper for integers more efficient for negative values.

 This encoding format enforces  `Zig-Zag` encoding, which is more efficient  when numbers are often negative.

 - Note: This wrapper is only useful when encoding and decoding to/from protobuf data.
 It has no effect for the standard `BinaryEncoder` and `BinaryDecoder`, where integer values are
 encoded using `Zig-Zag` encoding by default.

 Use the property wrapped within a `Codable` definition to enforce fixed-width encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Efficient for small positive and negative values
     @SignedValue
     var count: Int32
 }
 ```

The `SignedValue` property wrapper is supported for `Int`, `Int32`, and `Int64` types.

 - SeeAlso: [Laguage Guide (proto3): Scalar value types](https://developers.google.com/protocol-buffers/docs/proto3#scalar)
 */
@propertyWrapper
public struct SignedValue<WrappedValue>: ExpressibleByIntegerLiteral
where WrappedValue: SignedValueCompatible,
      WrappedValue: SignedInteger {

    public typealias IntegerLiteralType = WrappedValue.IntegerLiteralType

    /// The value wrapped in the fixed-size container
    public var wrappedValue: WrappedValue

    /**
     Wrap an integer value in a fixed-size container
     - Parameter wrappedValue: The integer to wrap
     */
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }

    public init(integerLiteral value: WrappedValue.IntegerLiteralType) {
        self.wrappedValue = WrappedValue.init(integerLiteral: value)
    }
}

extension SignedValue: Equatable where WrappedValue: Equatable {

}

extension SignedValue: Comparable where WrappedValue: Comparable {

    public static func < (lhs: SignedValue<WrappedValue>, rhs: SignedValue<WrappedValue>) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }
}

extension SignedValue: Hashable where WrappedValue: Hashable {

}

extension SignedValue: CodablePrimitive where WrappedValue: ZigZagCodable, WrappedValue: DataTypeProvider {

    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    func data() -> Data {
        wrappedValue.zigZagEncoded
    }

    init(decodeFrom data: Data) throws {
        let wrappedValue = try WrappedValue(fromZigZag: data)
        self.init(wrappedValue: wrappedValue)
    }
}

extension SignedValue: DataTypeProvider where WrappedValue: DataTypeProvider {

    /// The wire type of the wrapped value.
    static var dataType: DataType {
        WrappedValue.dataType
    }
}

extension SignedValue: Encodable where WrappedValue: Encodable {

    /**
     Encode the wrapped value transparently to the given encoder.
     - Parameter encoder: The encoder to use for encoding.
     - Throws: Errors from the decoder when attempting to encode a value in a single value container.
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self)
    }
}

extension SignedValue: Decodable where WrappedValue: Decodable {
    /**
     Decode a wrapped value from a decoder.
     - Parameter decoder: The decoder to use for decoding.
     - Throws: Errors from the decoder when reading a single value container or decoding the wrapped value from it.
     */
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try container.decode(Self.self)
    }
}

public extension SignedValue where WrappedValue: AdditiveArithmetic {

    /**
     The zero value.

     Zero is the identity element for addition. For any value, `x + .zero == x` and `.zero + x == x`.
     */
    static var zero: Self {
        .init(wrappedValue: .zero)
    }
}

public extension SignedValue where WrappedValue: FixedWidthInteger {

    /// The maximum representable integer in this type.
    ///
    /// For unsigned integer types, this value is `(2 ** bitWidth) - 1`, where
    /// `**` is exponentiation. For signed integer types, this value is
    /// `(2 ** (bitWidth - 1)) - 1`.
    static var max: Self {
        .init(wrappedValue: .max)
    }

    /// The minimum representable integer in this type.
    ///
    /// For unsigned integer types, this value is always `0`. For signed integer
    /// types, this value is `-(2 ** (bitWidth - 1))`, where `**` is
    /// exponentiation.
    static var min: Self {
        .init(wrappedValue: .min)
    }
}

extension SignedValue: ProtobufCodable where WrappedValue: ZigZagCodable, WrappedValue: SignedValueCompatible {

    func protobufData() throws -> Data {
        wrappedValue.zigZagEncoded
    }

    init(fromProtobuf data: Data) throws {
        let value = try WrappedValue(fromZigZag: data)
        self.init(wrappedValue: value)
    }

    var protoType: String {
        wrappedValue.positiveProtoType
    }
}
