import XCTest
@testable import BinaryCodable

final class KeyedEncodingTests: XCTestCase {

    func testEncodingWithVarintType() throws {
        struct Test: Codable, Equatable {
            let value: Int
        }
        let expected: [UInt8] = [0b01011000, 118, 97, 108, 117, 101, 123]
        try compare(Test(value: 123), to: expected)
    }

    func testEncodingWithByteType() throws {
        struct Test: Codable, Equatable {
            let value: Bool
        }
        let expected: [UInt8] = [0b01011110, 118, 97, 108, 117, 101, 1]
        try compare(Test(value: true), to: expected)
    }

    func testEncodingWithTwoByteType() throws {
        struct Test: Codable, Equatable {
            let value: Int16
        }
        let expected: [UInt8] = [0b01011111, 118, 97, 108, 117, 101, 0xD2, 0x04]
        try compare(Test(value: 1234), to: expected)
    }

    func testEncodingWithVariableLengthType() throws {
        struct Test: Codable, Equatable {
            let value: String
        }
        let expected: [UInt8] = [0b01011010, 118, 97, 108, 117, 101, 5, 118, 97, 108, 117, 101]
        try compare(Test(value: "value"), to: expected)
    }

    func testEncodingWithFourByteType() throws {
        struct Test: Codable, Equatable {
            let value: Float
        }
        let expected: [UInt8] = [0b01011101, 118, 97, 108, 117, 101, 0xDA, 0x0F, 0x49, 0x40]
        try compare(Test(value: .pi), to: expected)
    }

    func testEncodingWithEightByteType() throws {
        struct Test: Codable, Equatable {
            let value: Double
        }
        let expected: [UInt8] = [0b01011001, 118, 97, 108, 117, 101,
                                 0x18, 0x2D, 0x44, 0x54, 0xFB, 0x21, 0x09, 0xC0]
        try compare(Test(value: -.pi), to: expected)
    }

    func testStructEncodingIntegerKey() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            enum CodingKeys: Int, CodingKey {
                case value = 5
            }
        }
        let expected: [UInt8] = [0b01010111, 123, 0]
        try compare(Test(value: 123), to: expected)
    }

    func testStructEncodingLargeIntegerKey() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            enum CodingKeys: Int, CodingKey {
                case value = 5318273
            }
        }
        let expected: [UInt8] = [0b10010111, 0xD0, 0xC9, 0x28, 123, 0]
        try compare(Test(value: 123), to: expected)
    }

    func testStringDictEncoding() throws {
        // Dictionaries with string keys are treated as keyed containers
        let value: [String : UInt8] = ["val": 123, "more": 124]
        let part1: [UInt8] = [0b00111110, 118, 97, 108, 123]
        let part2: [UInt8] = [0b01001110, 109, 111, 114, 101, 124]
        try compare(value, possibleResults: [part1 + part2, part2 + part1])
    }

    func testIntDictEncoding() throws {
        // Dictionaries with int keys are treated as keyed containers
        let value: [Int : UInt8] = [123: 123, 124: 124]
        let part1: [UInt8] = [0b10110110, 0x0F, 123]
        let part2: [UInt8] = [0b11000110, 0x0F, 124]
        try compare(value, possibleResults: [part1 + part2, part2 + part1])
    }

    func testUIntDictEncoding() throws {
        // Other dictionaries (keys not int/string) are treated as unkeyed containers of key-value pairs
        let value: [UInt : UInt8] = [123: 123, 124: 124]
        let part1: [UInt8] = [123, 123]
        let part2: [UInt8] = [124, 124]
        try compare(value, possibleResults: [[0] + part1 + part2, [0] + part2 + part1])
    }
}
