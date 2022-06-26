import XCTest
@testable import BinaryCodable

final class KeyedEncodingTests: XCTestCase {

    func testEncodingWithVarintType() throws {
        struct Test: Codable {
            let value: Int
        }
        let expected: [UInt8] = [0b01010001, 118, 97, 108, 117, 101, 123]
        try compare(Test(value: 123), to: expected)
    }

    func testEncodingWithByteType() throws {
        struct Test: Codable {
            let value: Bool
        }
        let expected: [UInt8] = [0b01010011, 118, 97, 108, 117, 101, 1]
        try compare(Test(value: true), to: expected)
    }

    func testEncodingWithTwoByteType() throws {
        struct Test: Codable {
            let value: Int16
        }
        let expected: [UInt8] = [0b01010101, 118, 97, 108, 117, 101, 0xD2, 0x04]
        try compare(Test(value: 1234), to: expected)
    }

    func testEncodingWithVariableLengthType() throws {
        struct Test: Codable {
            let value: String
        }
        let expected: [UInt8] = [0b01010111, 118, 97, 108, 117, 101, 5, 118, 97, 108, 117, 101]
        try compare(Test(value: "value"), to: expected)
    }

    func testEncodingWithFourByteType() throws {
        struct Test: Codable {
            let value: Float
        }
        let expected: [UInt8] = [0b01011001, 118, 97, 108, 117, 101, 0x40, 0x49, 0x0F, 0xDA]
        try compare(Test(value: .pi), to: expected)
    }

    func testEncodingWithEightByteType() throws {
        struct Test: Codable {
            let value: Double
        }
        let expected: [UInt8] = [0b01011011, 118, 97, 108, 117, 101, 0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18]
        try compare(Test(value: -.pi), to: expected)
    }

    func testStructEncodingIntegerKey() throws {
        struct Test: Codable {
            let value: UInt16

            enum CodingKeys: Int, CodingKey {
                case value = 5
            }
        }
        let expected: [UInt8] = [0b01010100, 123, 0]
        try compare(Test(value: 123), to: expected)
    }

    func testStructEncodingLargeIntegerKey() throws {
        struct Test: Codable {
            let value: UInt16

            enum CodingKeys: Int, CodingKey {
                case value = 5318273
            }
        }
        let expected: [UInt8] = [0b10010100, 0xD0, 0xC9, 0x28, 123, 0]
        try compare(Test(value: 123), to: expected)
    }
}
