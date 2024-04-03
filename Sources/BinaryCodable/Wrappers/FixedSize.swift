import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a fixed size.

 Use the property wrapped within a `Codable` definition to enforce fixed-width encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Always encoded as 4 bytes
     @FixedSize
     var largeInteger: Int32
 }
 ```

The `FixedSize` property wrapper is supported for `UInt`, `UInt32`, `UInt64`, `Int`, `Int32`, and `Int64` types.

 - Warning: Do not conform other types to `FixedSizeCodable`. This will lead to crashes during encoding and decoding.
 - SeeAlso: [Laguage Guide (proto3): Scalar value types](https://developers.google.com/protocol-buffers/docs/proto3#scalar)
 */
@propertyWrapper
public struct FixedSize<WrappedValue> where WrappedValue: FixedSizeCodable, WrappedValue: FixedWidthInteger {

    /// The value wrapped in the fixed-size container
    public var wrappedValue: WrappedValue

    /**
     Wrap an integer value in a fixed-size container
     - Parameter wrappedValue: The integer to wrap
     */
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
}

extension FixedSize: Numeric {
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let wrapped = WrappedValue(exactly: source) else {
            return nil
        }
        self.init(wrappedValue: wrapped)
    }
    
    public var magnitude: WrappedValue.Magnitude {
        wrappedValue.magnitude
    }
    
    public static func * (lhs: FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) -> FixedSize<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue * rhs.wrappedValue)
    }

    public static func *= (lhs: inout FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) {
        lhs.wrappedValue *= rhs.wrappedValue
    }
}

extension FixedSize: AdditiveArithmetic {

    /**
     The zero value.

     Zero is the identity element for addition. For any value, x + .zero == x and .zero + x == x.
     */
    public static var zero: Self {
        .init(wrappedValue: .zero)
    }

    public static func - (lhs: FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) -> FixedSize<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue - rhs.wrappedValue)
    }

    public static func + (lhs: FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) -> FixedSize<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue + rhs.wrappedValue)
    }
}

extension FixedSize: BinaryInteger {

    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(wrappedValue: .init(source))
    }
    
    public static var isSigned: Bool {
        WrappedValue.isSigned
    }
    
    public var words: WrappedValue.Words {
        wrappedValue.words
    }
    
    public var trailingZeroBitCount: Int {
        wrappedValue.trailingZeroBitCount
    }
    
    public static func / (lhs: FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) -> FixedSize<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue / rhs.wrappedValue)
    }
    
    public static func % (lhs: FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) -> FixedSize<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue % rhs.wrappedValue)
    }
    
    public static func /= (lhs: inout FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) {
        lhs.wrappedValue /= rhs.wrappedValue
    }

    public static func %= (lhs: inout FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) {
        lhs.wrappedValue %= rhs.wrappedValue
    }
    
    public static func &= (lhs: inout FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) {
        lhs.wrappedValue &= rhs.wrappedValue
    }
    
    public static func |= (lhs: inout FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) {
        lhs.wrappedValue |= rhs.wrappedValue
    }
    
    public static func ^= (lhs: inout FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) {
        lhs.wrappedValue ^= rhs.wrappedValue
    }
}

extension FixedSize: FixedWidthInteger {

    public typealias Words = WrappedValue.Words

    public typealias Magnitude = WrappedValue.Magnitude

    public init<T>(_truncatingBits source: T) where T : BinaryInteger {
        self.init(wrappedValue: .init(source))
    }

    public func dividingFullWidth(_ dividend: (high: FixedSize<WrappedValue>, low: WrappedValue.Magnitude)) -> (quotient: FixedSize<WrappedValue>, remainder: FixedSize<WrappedValue>) {
        let result = wrappedValue.dividingFullWidth((high: dividend.high.wrappedValue, low: dividend.low))
        return (quotient: FixedSize(wrappedValue: result.quotient), remainder: FixedSize(wrappedValue: result.remainder))
    }

    public func addingReportingOverflow(_ rhs: FixedSize<WrappedValue>) -> (partialValue: FixedSize<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.addingReportingOverflow(rhs.wrappedValue)
        return (FixedSize(wrappedValue: result.partialValue), result.overflow)
    }

    public func subtractingReportingOverflow(_ rhs: FixedSize<WrappedValue>) -> (partialValue: FixedSize<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.subtractingReportingOverflow(rhs.wrappedValue)
        return (FixedSize(wrappedValue: result.partialValue), result.overflow)
    }

    public func multipliedReportingOverflow(by rhs: FixedSize<WrappedValue>) -> (partialValue: FixedSize<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.multipliedReportingOverflow(by: rhs.wrappedValue)
        return (FixedSize(wrappedValue: result.partialValue), result.overflow)
    }

    public func dividedReportingOverflow(by rhs: FixedSize<WrappedValue>) -> (partialValue: FixedSize<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.dividedReportingOverflow(by: rhs.wrappedValue)
        return (FixedSize(wrappedValue: result.partialValue), result.overflow)
    }

    public func remainderReportingOverflow(dividingBy rhs: FixedSize<WrappedValue>) -> (partialValue: FixedSize<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.remainderReportingOverflow(dividingBy: rhs.wrappedValue)
        return (FixedSize(wrappedValue: result.partialValue), result.overflow)
    }

    public static var bitWidth: Int {
        WrappedValue.bitWidth
    }

    public var nonzeroBitCount: Int {
        wrappedValue.nonzeroBitCount
    }
    
    public var leadingZeroBitCount: Int {
        wrappedValue.leadingZeroBitCount
    }
    
    public var byteSwapped: FixedSize<WrappedValue> {
        .init(wrappedValue: wrappedValue.byteSwapped)
    }
    
    /// The maximum representable integer in this type.
    ///
    /// For unsigned integer types, this value is `(2 ** bitWidth) - 1`, where
    /// `**` is exponentiation. For signed integer types, this value is
    /// `(2 ** (bitWidth - 1)) - 1`.
    public static var max: Self {
        .init(wrappedValue: .max)
    }

    /// The minimum representable integer in this type.
    ///
    /// For unsigned integer types, this value is always `0`. For signed integer
    /// types, this value is `-(2 ** (bitWidth - 1))`, where `**` is
    /// exponentiation.
    public static var min: Self {
        .init(wrappedValue: .min)
    }
}

extension FixedSize: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = WrappedValue.IntegerLiteralType

    public init(integerLiteral value: WrappedValue.IntegerLiteralType) {
        self.wrappedValue = WrappedValue.init(integerLiteral: value)
    }
}

extension FixedSize: Equatable {

    public static func == (lhs: FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension FixedSize: Comparable {

    public static func < (lhs: FixedSize<WrappedValue>, rhs: FixedSize<WrappedValue>) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }
}

extension FixedSize: Hashable { }

extension FixedSize: EncodablePrimitive where WrappedValue: EncodablePrimitive {

    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    var encodedData: Data {
        wrappedValue.fixedSizeEncoded
    }
}

extension FixedSize: DecodablePrimitive where WrappedValue: DecodablePrimitive {

    init(data: Data) throws {
        let wrappedValue = try WrappedValue(fromFixedSize: data)
        self.init(wrappedValue: wrappedValue)
    }
}

extension FixedSize: Encodable {

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

extension FixedSize: Decodable {
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
