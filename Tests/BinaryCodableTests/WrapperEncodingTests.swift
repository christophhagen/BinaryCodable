import XCTest
import BinaryCodable

final class WrapperEncodingTests: XCTestCase {

    func testFixedSizeWrapperInt32() throws {
        func compare(_ value: FixedSize<Int32>, to expected: [UInt8]) throws {
            try compareEncoding(FixedSize<Int32>.self, value: value, to: expected)
        }
        try compare(123, to: [123, 0, 0, 0])
        try compare(.max, to: [255, 255, 255, 127])
        try compare(.min, to: [0, 0, 0, 128])
    }

    func testFixedSizeWrapperInt64() throws {
        func compare(_ value: FixedSize<Int64>, to expected: [UInt8]) throws {
            try compareEncoding(FixedSize<Int64>.self, value: value, to: expected)
        }
        try compare(123, to: [123, 0, 0, 0, 0, 0, 0, 0])
        try compare(.max, to: [255, 255, 255, 255, 255, 255, 255, 127])
        try compare(.min, to: [0, 0, 0, 0, 0, 0, 0, 128])
    }

    func testFixedSizeWrapperUInt32() throws {
        func compare(_ value: FixedSize<UInt32>, to expected: [UInt8]) throws {
            try compareEncoding(FixedSize<UInt32>.self, value: value, to: expected)
        }
        try compare(123, to: [123, 0, 0, 0])
        try compare(.max, to: [255, 255, 255, 255])
        try compare(.min, to: [0, 0, 0, 0])
    }

    func testFixedSizeWrapperUInt64() throws {
        func compare(_ value: FixedSize<UInt64>, to expected: [UInt8]) throws {
            try compareEncoding(FixedSize<UInt64>.self, value: value, to: expected)
        }
        try compare(123, to: [123, 0, 0, 0, 0, 0, 0, 0])
        try compare(.max, to: [255, 255, 255, 255, 255, 255, 255, 255])
        try compare(.min, to: [0, 0, 0, 0, 0, 0, 0, 0])
    }

    func testFixedInt32InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: Int32
        }
        try compare(Test(val: 123), to: [0b00111101, 118, 97, 108,
                                         123, 0, 0, 0])
    }

    func testFixedInt64InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: Int64
        }
        try compare(Test(val: 123), to: [0b00111001, 118, 97, 108,
                                         123, 0, 0, 0, 0, 0, 0, 0])
    }

    func testFixedUInt32InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: UInt32
        }
        try compare(Test(val: 123), to: [0b00111101, 118, 97, 108,
                                         123, 0, 0, 0])
    }

    func testFixedUInt64InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: UInt64
        }
        try compare(Test(val: 123), to: [0b00111001, 118, 97, 108,
                                         123, 0, 0, 0, 0, 0, 0, 0])
    }

    func testPositiveIntegerWrapperInt32() throws {
        func compare(_ value: PositiveInteger<Int32>, to expected: [UInt8]) throws {
            try compareEncoding(PositiveInteger<Int32>.self, value: value, to: expected)
        }
        try compare(.zero, to: [0])
        try compare(123, to: [123])
        try compare(.max, to: [255, 255, 255, 255, 7])
        try compare(.min, to: [128, 128, 128, 128, 8])
    }

    func testPositiveIntegerWrapperInt64() throws {
        func compare(_ value: PositiveInteger<Int64>, to expected: [UInt8]) throws {
            try compareEncoding(PositiveInteger<Int64>.self, value: value, to: expected)
        }
        try compare(.zero, to: [0])
        try compare(123, to: [123])
        try compare(.max, to: [255, 255, 255, 255, 255, 255, 255, 255, 127])
        try compare(.min, to: [128, 128, 128, 128, 128, 128, 128, 128, 128])
    }

    func testPositiveIntegerWrapperInt() throws {
        func compare(_ value: PositiveInteger<Int>, to expected: [UInt8]) throws {
            try compareEncoding(PositiveInteger<Int>.self, value: value, to: expected)
        }
        try compare(.zero, to: [0])
        try compare(123, to: [123])
        try compare(.max, to: [255, 255, 255, 255, 255, 255, 255, 255, 127])
        try compare(.min, to: [128, 128, 128, 128, 128, 128, 128, 128, 128])
    }

    func testPositiveInt32InStruct() throws {
        struct Test: Codable, Equatable {

            @PositiveInteger
            var val: Int32
        }
        try compare(Test(val: .zero), to: [0b00111000, 118, 97, 108, 0])
        try compare(Test(val: 123), to: [0b00111000, 118, 97, 108, 123])
        try compare(Test(val: .max), to: [0b00111000, 118, 97, 108, 255, 255, 255, 255, 7])
        try compare(Test(val: .min), to: [0b00111000, 118, 97, 108, 128, 128, 128, 128, 8])
    }

    func testPositiveInt64InStruct() throws {
        struct Test: Codable, Equatable {

            @PositiveInteger
            var val: Int64
        }
        try compare(Test(val: .zero), to: [0b00111000, 118, 97, 108, 0])
        try compare(Test(val: 123), to: [0b00111000, 118, 97, 108, 123])
        try compare(Test(val: .max), to: [0b00111000, 118, 97, 108, 255, 255, 255, 255, 255, 255, 255, 255, 127])
        try compare(Test(val: .min), to: [0b00111000, 118, 97, 108, 128, 128, 128, 128, 128, 128, 128, 128, 128])
    }

    func testPositiveIntInStruct() throws {
        struct Test: Codable, Equatable {

            @PositiveInteger
            var val: Int
        }
        try compare(Test(val: .zero), to: [0b00111000, 118, 97, 108, 0])
        try compare(Test(val: 123), to: [0b00111000, 118, 97, 108, 123])
        try compare(Test(val: .max), to: [0b00111000, 118, 97, 108, 255, 255, 255, 255, 255, 255, 255, 255, 127])
        try compare(Test(val: .min), to: [0b00111000, 118, 97, 108, 128, 128, 128, 128, 128, 128, 128, 128, 128])
    }
}
