import XCTest
import BinaryCodable

final class EnumEncodingTests: XCTestCase {

    func testEnumEncoding() throws {
        enum Test: Codable, Equatable {
            case one
            case two
        }
        let expected1: [UInt8] = [
            7, /// `String` key, length `3`
            111, 110, 101, /// String key `one`
            0 /// Encodes `0` as the `value`
        ]
        try compare(Test.one, to: expected1)

        let expected2: [UInt8] = [
            7, /// `String` key, length `3`
            116, 119, 111, /// String key `one`
            0 /// Encodes `0` as the `value`
        ]
        try compare(Test.two, to: expected2)
    }

    func testIntEnumEncoding() throws {
        enum Test: Int, Codable, Equatable {
            case one = 1
            case two = 2
        }
        try compare(Test.one, to: [0, 2]) // Nil indicator + raw value
        try compare(Test.two, to: [0, 4])
    }

    func testStringEnumEncoding() throws {
        enum Test: String, Codable, Equatable {
            case one = "one"
            case two = "two"
        }
        try compare(Test.one, to: [0, 111, 110, 101])
        try compare(Test.two, to: [0, 116, 119, 111])
    }

    func testEnumWithAssociatedValues() throws {
        /**
         Note: `Codable` encoded associated values using the string keys `_0`, `_1`, ...
         This depends on the number of associated values
         */
        enum Test: Codable, Equatable {

            case one(String)
            case two(Int)
            case three(Data)
            case four(Bool)
            case five(UInt, Int8)
        }
        try compare(Test.one("Some"), to: [
            7, // String key, length 3
            111, 110, 101, // String "one"
            16, // Length 8
            5, // String key, length 2
            95, 48, // String "_0"
            8, // Length 4
            83, 111, 109, 101 // String "Some"
        ])
        try compare(Test.two(123), to: [
            7, // String key, length 3
            116, 119, 111, // String "two"
            12, // Length 6
            5, // String key, length 2
            95, 48,  // String "_0"
            4, // Length 2
            246, 1 // Int(123)
        ])
        try compare(Test.three(.init(repeating: 42, count: 3)), to: [
            11, // String key, length 5
            116, 104, 114, 101, 101, // String "three"
            14, // Length 7
            5, // String key, length 2
            95, 48,  // String "_0"
            6, // Length 3
            42, 42, 42 // Data(42, 42, 42)
        ])

        try compare(Test.four(true), to: [
            9, // String key, length 4
            102, 111, 117, 114, // String "four"
            10, // Length 5
            5, // String key, length 2
            95, 48,  // String "_0"
            2, 1 // Bool(true)
        ])

        let start: [UInt8] = [
            9, // String key, length 4
            102, 105, 118, 101, // String "five"
            20] // Length 10
        let a: [UInt8] = [
            5, // String key, length 2
            95, 48, // String "_0"
            2, // Length 1
            123] // UInt(123)
        let b: [UInt8] = [
            5, // String key, length 2
            95, 49, // String "_1"
            2,  // Length 1
            133] // Int8(-123)
        try compare(Test.five(123, -123), toOneOf: [start + a + b, start + b + a])

        struct Wrap: Codable, Equatable {

            let value: Test

            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }

        try compare(Wrap(value: .four(true)), to: [
            2, // Int key '1'
            22, // Length 11
            9, // String key, length 4
            102, 111, 117, 114, // String "four"
            10, // Length 5
            5, // String key, length 2
            95, 48,  // String "_0"
            2, // Length 1
            1 // Bool(true)
        ])
    }

    func testEnumWithAssociatedValuesAndIntegerKeys() throws {
        enum Test: Codable, Equatable {

            case one(String)
            case two(Int)
            case three(Data)
            case four(Bool)
            case five(UInt, Int8)

            enum CodingKeys: Int, CodingKey {
                case one = 1
                case two = 2
                case three = 3
                case four = 4
                case five = 5
            }
        }

        try compare(Test.one("Some"), to: [
            2, // Int key 1
            16, // Length 8
            5, // String key, length 2
            95, 48, // String "_0"
            8, // Length 4
            83, 111, 109, 101 // String "Some"
        ])

        try compare(Test.two(123), to: [
            4, // Int key 2
            12, // Length 6
            5, // String key, length 2
            95, 48,  // String "_0"
            4, // Length 2
            246, 1 // Int(123)
        ])

        try compare(Test.three(.init(repeating: 42, count: 3)), to: [
            6, // Int key 3
            14, // Length 7
            5, // String key, length 2
            95, 48,  // String "_0"
            6, // Length 3
            42, 42, 42 // Data(42, 42, 42)
        ])

        try compare(Test.four(true), to: [
            8, // Int key 4
            10, // Length 5
            5, // String key, length 2
            95, 48,  // String "_0"
            2, // Length 1
            1 // Bool(true)
        ])

        let start: [UInt8] = [
            10, // Int key 5
            20] // Length 10
        let a: [UInt8] = [
            5, // String key, length 2
            95, 48, // String "_0"
            2, // Length 1
            123] // UInt(123)
        let b: [UInt8] = [
            5, // String key, length 2
            95, 49, // String "_1"
            2, // Length 1
            133] // Int8(-123)
        try compare(Test.five(123, -123), toOneOf: [start + a + b, start + b + a])
    }

    func testDecodeUnknownCase() throws {
        enum Test: Int, Codable {
            case one // No raw value assigns 0
        }

        try compare(Test.one, to: [0, 0]) // Nil indicator + RawValue 0

        let decoder = BinaryDecoder()
        do {
            _ = try decoder.decode(Test.self, from: Data([0, 1]))
            XCTFail("Enum decoding should fail for unknown case")
        } catch DecodingError.dataCorrupted(let context) {
            XCTAssertEqual(context.codingPath, [])
            // Correct error
        }
    }
}
