import Foundation

/**
 A wrapper for integer values which ensures that values are encoded in binary format using a fixed size.

 Use the property wrapped within a `Codable` definition to enforce fixed-width encoding for a property:
 ```swift
 struct MyStruct: Codable {

     /// Always encoded as 4 bytes
     @FixedSizeEncoded
     var largeInteger: Int32
 }
 ```

The `FixedSizeEncoded` property wrapper is supported for `UInt`, `UInt32`, `UInt64`, `Int`, `Int32`, and `Int64` types.

 - Warning: Do not conform other types to `FixedSizeCodable`. This will lead to crashes during encoding and decoding.
 - SeeAlso: [Language Guide (proto3): Scalar value types](https://developers.google.com/protocol-buffers/docs/proto3#scalar)
 */
@propertyWrapper
public struct FixedSizeEncoded<WrappedValue> where WrappedValue: FixedSizeCodable {

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

// MARK: - Fixed size

extension FixedSizeEncoded: EncodablePrimitive where WrappedValue: EncodablePrimitive {

    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    var encodedData: Data {
        wrappedValue.fixedSizeEncoded
    }
}

extension FixedSizeEncoded: DecodablePrimitive where WrappedValue: DecodablePrimitive {

    init(data: Data) throws {
        let wrappedValue = try WrappedValue(fromFixedSize: data)
        self.init(wrappedValue: wrappedValue)
    }
}

// MARK: - Codable

extension FixedSizeEncoded: Encodable {

    /**
     Encode the wrapped value transparently to the given encoder.
     - Parameter encoder: The encoder to use for encoding.
     - Throws: Errors from the decoder when attempting to encode a value in a single value container.
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension FixedSizeEncoded: Decodable {
    /**
     Decode a wrapped value from a decoder.
     - Parameter decoder: The decoder to use for decoding.
     - Throws: Errors from the decoder when reading a single value container or decoding the wrapped value from it.
     */
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(WrappedValue.self)
    }
}

extension FixedSizeEncoded: Equatable where WrappedValue: Equatable {

}

extension FixedSizeEncoded: Hashable where WrappedValue: Hashable {

}

extension FixedSizeEncoded: Comparable where WrappedValue: Comparable {

    public static func < (lhs: FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) -> Bool {
        lhs.wrappedValue < rhs.wrappedValue
    }
}

extension FixedSizeEncoded: CustomStringConvertible where WrappedValue: CustomStringConvertible {
    
    public var description: String {
        wrappedValue.description
    }
}

extension FixedSizeEncoded: Numeric where WrappedValue: Numeric {

    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let wrapped = WrappedValue(exactly: source) else {
            return nil
        }
        self.init(wrappedValue: wrapped)
    }

    public var magnitude: WrappedValue.Magnitude {
        wrappedValue.magnitude
    }

    public static func * (lhs: FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) -> FixedSizeEncoded<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue * rhs.wrappedValue)
    }

    public static func *= (lhs: inout FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) {
        lhs.wrappedValue *= rhs.wrappedValue
    }
}

extension FixedSizeEncoded: AdditiveArithmetic where WrappedValue: AdditiveArithmetic {

    /**
     The zero value.

     Zero is the identity element for addition. For any value, x + .zero == x and .zero + x == x.
     */
    public static var zero: Self {
        .init(wrappedValue: .zero)
    }

    public static func - (lhs: FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) -> FixedSizeEncoded<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue - rhs.wrappedValue)
    }

    public static func + (lhs: FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) -> FixedSizeEncoded<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue + rhs.wrappedValue)
    }
}

extension FixedSizeEncoded: Strideable where WrappedValue: Strideable {


    public typealias Stride = WrappedValue.Stride

    public func distance(to other: FixedSizeEncoded<WrappedValue>) -> WrappedValue.Stride {
        wrappedValue.distance(to: other.wrappedValue)
    }

    public func advanced(by n: WrappedValue.Stride) -> FixedSizeEncoded<WrappedValue> {
        .init(wrappedValue: wrappedValue.advanced(by: n))
    }
}

extension FixedSizeEncoded: BinaryInteger where WrappedValue: BinaryInteger {
    
    public static func <<= <RHS>(lhs: inout FixedSizeEncoded<WrappedValue>, rhs: RHS) where RHS : BinaryInteger {
        lhs.wrappedValue <<= rhs
    }
    
    public static func >>= <RHS>(lhs: inout FixedSizeEncoded<WrappedValue>, rhs: RHS) where RHS : BinaryInteger {
        lhs.wrappedValue >>= rhs
    }

    public static prefix func ~ (x: FixedSizeEncoded<WrappedValue>) -> FixedSizeEncoded<WrappedValue> {
        .init(wrappedValue: ~x.wrappedValue)
    }
    
    public var bitWidth: Int {
        wrappedValue.bitWidth
    }

    public init<T>(clamping source: T) where T : BinaryInteger {
        self.wrappedValue = .init(clamping: source)
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.wrappedValue = .init(truncatingIfNeeded: source)
    }
    
    public init<T>(_ source: T) where T : BinaryFloatingPoint {
        self.wrappedValue = .init(source)
    }
    
    public init?<T>(exactly source: T) where T : BinaryFloatingPoint {
        guard let wrappedValue = WrappedValue(exactly: source) else {
            return nil
        }
        self.wrappedValue = wrappedValue
    }

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

    public static func / (lhs: FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) -> FixedSizeEncoded<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue / rhs.wrappedValue)
    }

    public static func % (lhs: FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) -> FixedSizeEncoded<WrappedValue> {
        .init(wrappedValue: lhs.wrappedValue % rhs.wrappedValue)
    }

    public static func /= (lhs: inout FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) {
        lhs.wrappedValue /= rhs.wrappedValue
    }

    public static func %= (lhs: inout FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) {
        lhs.wrappedValue %= rhs.wrappedValue
    }

    public static func &= (lhs: inout FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) {
        lhs.wrappedValue &= rhs.wrappedValue
    }

    public static func |= (lhs: inout FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) {
        lhs.wrappedValue |= rhs.wrappedValue
    }

    public static func ^= (lhs: inout FixedSizeEncoded<WrappedValue>, rhs: FixedSizeEncoded<WrappedValue>) {
        lhs.wrappedValue ^= rhs.wrappedValue
    }
}

extension FixedSizeEncoded: LosslessStringConvertible where WrappedValue: LosslessStringConvertible {

    public init?(_ description: String) {
        guard let wrappedValue = WrappedValue(description) else {
            return nil
        }
        self.wrappedValue = wrappedValue
    }
}

extension FixedSizeEncoded: FixedWidthInteger where WrappedValue: FixedWidthInteger {

    public typealias Words = WrappedValue.Words

    public typealias Magnitude = WrappedValue.Magnitude

    public init<T>(_truncatingBits source: T) where T : BinaryInteger {
        self.init(wrappedValue: .init(source))
    }

    public func dividingFullWidth(_ dividend: (high: FixedSizeEncoded<WrappedValue>, low: WrappedValue.Magnitude)) -> (quotient: FixedSizeEncoded<WrappedValue>, remainder: FixedSizeEncoded<WrappedValue>) {
        let result = wrappedValue.dividingFullWidth((high: dividend.high.wrappedValue, low: dividend.low))
        return (quotient: FixedSizeEncoded(wrappedValue: result.quotient), remainder: FixedSizeEncoded(wrappedValue: result.remainder))
    }

    public func addingReportingOverflow(_ rhs: FixedSizeEncoded<WrappedValue>) -> (partialValue: FixedSizeEncoded<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.addingReportingOverflow(rhs.wrappedValue)
        return (FixedSizeEncoded(wrappedValue: result.partialValue), result.overflow)
    }

    public func subtractingReportingOverflow(_ rhs: FixedSizeEncoded<WrappedValue>) -> (partialValue: FixedSizeEncoded<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.subtractingReportingOverflow(rhs.wrappedValue)
        return (FixedSizeEncoded(wrappedValue: result.partialValue), result.overflow)
    }

    public func multipliedReportingOverflow(by rhs: FixedSizeEncoded<WrappedValue>) -> (partialValue: FixedSizeEncoded<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.multipliedReportingOverflow(by: rhs.wrappedValue)
        return (FixedSizeEncoded(wrappedValue: result.partialValue), result.overflow)
    }

    public func dividedReportingOverflow(by rhs: FixedSizeEncoded<WrappedValue>) -> (partialValue: FixedSizeEncoded<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.dividedReportingOverflow(by: rhs.wrappedValue)
        return (FixedSizeEncoded(wrappedValue: result.partialValue), result.overflow)
    }

    public func remainderReportingOverflow(dividingBy rhs: FixedSizeEncoded<WrappedValue>) -> (partialValue: FixedSizeEncoded<WrappedValue>, overflow: Bool) {
        let result = wrappedValue.remainderReportingOverflow(dividingBy: rhs.wrappedValue)
        return (FixedSizeEncoded(wrappedValue: result.partialValue), result.overflow)
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

    public var byteSwapped: FixedSizeEncoded<WrappedValue> {
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

extension FixedSizeEncoded: ExpressibleByIntegerLiteral where WrappedValue: ExpressibleByIntegerLiteral {

    public typealias IntegerLiteralType = WrappedValue.IntegerLiteralType

    public init(integerLiteral value: WrappedValue.IntegerLiteralType) {
        self.wrappedValue = WrappedValue.init(integerLiteral: value)
    }
}
