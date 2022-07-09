import XCTest
import BinaryCodable

final class StructEncodingTests: XCTestCase {

    func testStructWithArray() throws {
        struct Test: Codable, Equatable {
            let val: [Bool]
        }
        let expected: [UInt8] = [0b00111010, 118, 97, 108,
                                 4, 0, 1, 0, 1]
        try compare(Test(val: [true, false, true]), to: expected)
    }

    func testArrayOfStructs() throws {
        struct Test: Codable, Equatable {
            let val: Int
        }
        let value = [Test(val: 123), Test(val: 124)]
        let expected: [UInt8] = [
            0, // nil index set
            6, // Length of first element
            0b00111000, 118, 97, 108, // String key 'val', varint
            246, 1, // Value '123'
            6, // Length of second element
            0b00111000, 118, 97, 108, // String key 'val', varint
            248, 1, // Value '124'
        ]
        try compare(value, to: expected)
    }

    func testArrayOfOptionalStructs() throws {
        struct Test: Codable, Equatable {
            let val: Int
        }
        let value: [Test?] = [Test(val: 123), nil, Test(val: 124)]
        let expected: [UInt8] = [
            1, 1, // nil index set
            6, // Length of first element
            0b00111000, 118, 97, 108, // String key 'val', varint
            246, 1, // Value '123'
            6, // Length of third element
            0b00111000, 118, 97, 108, // String key 'val', varint
            248, 1, // Value '124'
        ]
        try compare(value, to: expected)
    }

    func testNegativeIntegerKeys() throws {
        struct Test: Codable, Equatable {
            let val: Bool

            enum CodingKeys: Int, CodingKey {
                case val = -1
            }
        }
        let value = Test(val: true)
        let expected: [UInt8] = [
            0b11110000, // Int key, varint, three LSB of int key
            255, 255, 255, 255, 255, 255, 255, 255,
            1, /// Bool `true`
        ]
        try compare(value, to: expected)
    }

    func testIntegerKeysLowerBound() throws {
        // 0x87FFFFFFFFFFFFFF  -8646911284551352321 decoded as: 0x07FFFFFFFFFFFFFF (576460752303423487)
        // 0x8FFFFFFFFFFFFFFF  -8070450532247928833 decoded as: -1
        // 0xE000000000000000  -2305843009213693952 decoded as: 0
        // 0xF000000000000000  -1152921504606846976 decoded as: 0
        // 0xF800000000000000   -576460752303423488 decoded
        // 0xF7FFFFFFFFFFFFFF   -576460752303423489 decoded as: 576460752303423487
        struct TestLowBound: Codable, Equatable {
            let val: Bool

            enum CodingKeys: Int, CodingKey {
                case val = -576460752303423488
            }
        }
        let value = TestLowBound(val: true)
        let expected: [UInt8] = [
            0b10000000, // Int key, varint, three LSB of int key
            128, 128, 128, 128, 128, 128, 128, 128,
            1, /// Bool `true`
        ]
        try compare(value, to: expected)
    }

    func testIntegerKeysHighBound() throws {
        print(Int(bitPattern: 0x07FFFFFFFFFFFFFF))
        struct TestHighBound: Codable, Equatable {
            let val: Bool

            enum CodingKeys: Int, CodingKey {
                case val = 576460752303423487
            }
        }
        let value = TestHighBound(val: true)
        let expected: [UInt8] = [
            0b11110000, // Int key, varint, three LSB of int key
            255, 255, 255, 255, 255, 255, 255, 127,
            1, /// Bool `true`
        ]
        try compare(value, to: expected)
    }
}
