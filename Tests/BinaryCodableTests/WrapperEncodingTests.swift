import XCTest
@testable import BinaryCodable

final class WrapperEncodingTests: XCTestCase {

    private func compareFixed<T>(_ value: FixedSize<T>, of type: T.Type, to expected: [UInt8]) throws where T: FixedSizeCodable, T: CodablePrimitive {
        try compareEncoding(of: value, withType: FixedSize<T>.self, isEqualTo: expected)
    }

    func testFixedSizeWrapperInt() throws {
        try compareFixed(123, of: Int.self, to: [123, 0, 0, 0, 0, 0, 0, 0])
        try compareFixed(.max, of: Int.self, to: [255, 255, 255, 255, 255, 255, 255, 127])
        try compareFixed(.min, of: Int.self, to: [0, 0, 0, 0, 0, 0, 0, 128])
    }

    func testFixedSizeWrapperInt32() throws {
        try compareFixed(123, of: Int32.self, to: [123, 0, 0, 0])
        try compareFixed(.max, of: Int32.self, to: [255, 255, 255, 127])
        try compareFixed(.min, of: Int32.self, to: [0, 0, 0, 128])
    }

    func testFixedSizeWrapperInt64() throws {
        try compareFixed(123, of: Int64.self, to: [123, 0, 0, 0, 0, 0, 0, 0])
        try compareFixed(.max, of: Int64.self, to: [255, 255, 255, 255, 255, 255, 255, 127])
        try compareFixed(.min, of: Int64.self, to: [0, 0, 0, 0, 0, 0, 0, 128])
    }

    func testFixedSizeWrapperUInt32() throws {
        try compareFixed(123, of: UInt32.self, to: [123, 0, 0, 0])
        try compareFixed(.max, of: UInt32.self, to: [255, 255, 255, 255])
        try compareFixed(.min, of: UInt32.self, to: [0, 0, 0, 0])
    }

    func testFixedSizeWrapperUInt64() throws {
        try compareFixed(123, of: UInt64.self, to: [123, 0, 0, 0, 0, 0, 0, 0])
        try compareFixed(.max, of: UInt64.self, to: [255, 255, 255, 255, 255, 255, 255, 255])
        try compareFixed(.min, of: UInt64.self, to: [0, 0, 0, 0, 0, 0, 0, 0])
    }

    func testFixedSizeWrapperUInt() throws {
        try compareFixed(123, of: UInt.self, to: [123, 0, 0, 0, 0, 0, 0, 0])
        try compareFixed(.max, of: UInt.self, to: [255, 255, 255, 255, 255, 255, 255, 255])
        try compareFixed(.min, of: UInt.self, to: [0, 0, 0, 0, 0, 0, 0, 0])
    }

    func testFixedIntInStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: Int
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            16, // Length 8
            123, 0, 0, 0, 0, 0, 0, 0 // '123'
        ])

        try compare(Test(val: -123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            16, // Length 8
            133, 255, 255, 255, 255, 255, 255, 255 // '-123'
        ])
    }

    func testFixedInt32InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: Int32
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            8, // Length 4
            123, 0, 0, 0 // '123'
        ])

        try compare(Test(val: -123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            8, // Length 4
            133, 255, 255, 255 // '-123'
        ])
    }

    func testFixedInt64InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: Int64
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            16, // Length 8
            123, 0, 0, 0, 0, 0, 0, 0 // '123'
        ])

        try compare(Test(val: -123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            16, // Length 8
            133, 255, 255, 255, 255, 255, 255, 255 // '-123'
        ])
    }

    func testFixedUInt32InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: UInt32
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            8, // Length 4
            123, 0, 0, 0 // '123'
        ])
    }

    func testFixedUInt64InStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var val: UInt64
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            16, // Length 8
            123, 0, 0, 0, 0, 0, 0, 0 // '123'
        ])
    }
}
