import XCTest
import BinaryCodable

final class EnumEncodingTests: XCTestCase {

    func testEnumEncoding() throws {
        enum Test: Codable, Equatable {
            case one
            case two
        }
        let expected1: [UInt8] = [
            0b00111010, /// `String` key, length `3`
            111, 110, 101, /// String key `one`
            0 /// Encodes `0` as the `value`
        ]
        try compare(Test.one, to: expected1)

        let expected2: [UInt8] = [
            0b00111010, /// `String` key, length `3`
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
        try compare(Test.one, to: [2])
        try compare(Test.two, to: [4])
    }

    func testStringEnumEncoding() throws {
        enum Test: String, Codable, Equatable {
            case one = "one"
            case two = "two"
        }
        try compare(Test.one, to: [111, 110, 101])
        try compare(Test.two, to: [116, 119, 111])
    }
}
