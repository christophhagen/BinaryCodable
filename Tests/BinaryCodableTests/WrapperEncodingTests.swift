import XCTest
@testable import BinaryCodable

final class WrapperEncodingTests: XCTestCase {

    private func compareFixed<T>(_ value: FixedSizeEncoded<T>, of type: T.Type, to expected: [UInt8]) throws where T: FixedSizeCodable, T: CodablePrimitive {
        try compareEncoding(of: value, withType: FixedSizeEncoded<T>.self, isEqualTo: expected)
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
    
    /**
     This test, if uncommented, should just produce warnings for the properties a,b,c
     */
    /*
    func testFixedSizeInitializerWarnings() {
        struct Test {
            @FixedSizeEncoded
            var a: Int16
            
            @FixedSizeEncoded
            var b: UInt16
        }
    }
     */

    func testFixedIntInStruct() throws {
        struct Test: Codable, Equatable {

            @FixedSizeEncoded
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

            @FixedSizeEncoded
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

            @FixedSizeEncoded
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

            @FixedSizeEncoded
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

            @FixedSizeEncoded
            var val: UInt64
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            16, // Length 8
            123, 0, 0, 0, 0, 0, 0, 0 // '123'
        ])
    }
    
    func testZigZagInt16() throws {
        func compareInt16(_ value: ZigZagEncoded<Int16>) throws {
            let expected = Int64(value).zigZagEncoded
            try compareEncoding(of: value, withType: ZigZagEncoded<Int16>.self, isEqualTo: expected.bytes)
        }
        try compareInt16(1)
        try compareInt16(123)
        try compareInt16(.min)
        try compareInt16(.max)
        try compareInt16(.zero)
    }
    
    func testZigZagInt16InStruct() throws {
        struct Test: Codable, Equatable {
            @ZigZagEncoded
            var val: Int16
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            4, // Length 2
            246, 1 // '123'
        ])
    }
    
    /**
     This test, if uncommented, should just produce warnings for the properties a,b,c
     */
    /*
    func testZigZagInitializerWarnings() {
        struct Test {
            @ZigZagEncoded
            var a: Int32
            
            @ZigZagEncoded
            var b: Int64
            
            @ZigZagEncoded
            var c: Int
        }
    }
     */
    
    func testVariableLengthInt32() throws {
        try compare(VariableLengthEncoded<Int32>(123), to: [123])
    }
    
    func testVariableLengthInt64() throws {
        try compare(VariableLengthEncoded<Int64>(123), to: [123])
    }
    
    func testVariableLengthInt() throws {
        try compare(VariableLengthEncoded<Int>(123), to: [123])
    }
    
    func testVariableLengthInt32InStruct() throws {
        struct Test: Codable, Equatable {
            @VariableLengthEncoded
            var val: Int32
        }
        
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            2, // Length 1
            123 // Int 123, variable-length encoded
        ])
    }
    
    func testVariableLengthInt64InStruct() throws {
        struct Test: Codable, Equatable {
            @VariableLengthEncoded
            var val: Int64
        }
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            2, // Length 1
            123 // Int 123, variable-length encoded
        ])
    }
    
    func testVariableLengthIntInStruct() throws {
        struct Test: Codable, Equatable {
            @VariableLengthEncoded
            var val: Int
        }
        
        try compare(Test(val: 123), to: [
            7, // String key, length 3
            118, 97, 108, // "val"
            2, // Length 1
            123 // Int 123, variable-length encoded
        ])
    }
}
