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
    
    func testSortingStructKeys() throws {
        struct Test: Codable, Equatable {
            
            let one: Int
            
            let two: String
            
            let three: Bool
            
            enum CodingKeys: Int, CodingKey {
                case one = 1
                case two = 2
                case three = 3
            }
        }
        
        let val = Test(one: 123, two: "Some", three: true)
        try compare(val, to: [
            0x10, // Int key(1), VarInt
            246, 1, // Int(123)
            0x22, // Int key(2), VarLen
            4, // Length 4
            83, 111, 109, 101, // String "Some"
            0x30, // Int key(3), VarInt
            1, // Bool(true)
        ], sort: true)
    }
}
