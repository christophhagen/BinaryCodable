import XCTest
import BinaryCodable

final class KeyedEncodingTests: XCTestCase {

    func testEncodingWithVarintType() throws {
        struct Test: Codable, Equatable {
            let value: Int
        }
        let expected: [UInt8] = [0b01011000, 118, 97, 108, 117, 101, 246, 1]
        try compare(Test(value: 123), to: expected)
    }

    func testEncodingWithByteType() throws {
        struct Test: Codable, Equatable {
            let value: UInt8
        }
        let expected: [UInt8] = [0b01011110, 118, 97, 108, 117, 101, 1]
        try compare(Test(value: 1), to: expected)
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
        let expected: [UInt8] = [0b01011101, 118, 97, 108, 117, 101, 0x40, 0x49, 0x0F, 0xDA]
        try compare(Test(value: .pi), to: expected)
    }

    func testEncodingWithEightByteType() throws {
        struct Test: Codable, Equatable {
            let value: Double
        }
        let expected: [UInt8] = [0b01011001, 118, 97, 108, 117, 101,
                                 0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18]
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
    
    func testSortingStringDictEncoding() throws {
        // Dictionaries with string keys are treated as keyed containers
        let value: [String : UInt8] = ["val": 123, "more": 124]
        try compare(value, to: [
            0b01001110, 109, 111, 114, 101, 124, // More
            0b00111110, 118, 97, 108, 123, // Val
        ], sort: true)
    }
    
    func testMixedStringIntegerKeyedDictionary() throws {
        // Strings which can be converted to integers are encoded as such
        // So the string "0" is actually encoded as Int key(0)
        let value: [String : UInt8] = ["val": 123, "0": 124]
        let part1: [UInt8] = [0b00111110, 118, 97, 108, 123] // "Val"
        let part2: [UInt8] = [0b00000110, 124] // Int key(0), UInt8(123)
        try compare(value, possibleResults: [part1 + part2, part2 + part1])
    }

    func testIntDictEncoding() throws {
        // Dictionaries with int keys are treated as keyed containers
        let value: [Int : UInt8] = [123: 123, 124: 124]
        let part1: [UInt8] = [0b10110110, 0x0F, 123]
        let part2: [UInt8] = [0b11000110, 0x0F, 124]
        try compare(value, possibleResults: [part1 + part2, part2 + part1])
    }
    
    func testSortingIntDictEncoding() throws {
        // Dictionaries with int keys are treated as keyed containers
        let value: [Int : UInt8] = [123: 123, 124: 124, 125: 125, 126: 126]
        try compare(value, to: [
            0b10110110, 0x0F, 123,
            0b11000110, 0x0F, 124,
            0b11010110, 0x0F, 125,
            0b11100110, 0x0F, 126
        ], sort: true)
    }

    func testUIntDictEncoding() throws {
        // Other dictionaries (keys not int/string) are treated as unkeyed containers of key-value pairs
        let value: [UInt : UInt8] = [123: 123, 124: 124]
        let part1: [UInt8] = [123, 123]
        let part2: [UInt8] = [124, 124]
        try compare(value, possibleResults: [part1 + part2, part2 + part1])
    }
}
