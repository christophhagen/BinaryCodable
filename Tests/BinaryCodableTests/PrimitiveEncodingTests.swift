import XCTest
@testable import BinaryCodable

final class PrimitiveEncodingTests: XCTestCase {

    func testBoolEncoding() throws {
        try compareEncoding(of: true, isEqualTo: [1])
        try compareEncoding(of: false, isEqualTo: [0])
    }

    func testInt8Encoding() throws {
        try compareEncoding(of: .zero, withType: Int8.self, isEqualTo: [0])
        try compareEncoding(of: 123, withType: Int8.self, isEqualTo: [123])
        try compareEncoding(of: .min, withType: Int8.self, isEqualTo: [128])
        try compareEncoding(of: .max, withType: Int8.self, isEqualTo: [127])
        try compareEncoding(of: -1, withType: Int8.self, isEqualTo: [255])
    }

    func testInt16Encoding() throws {
        try compareEncoding(of: .zero, withType: Int16.self, isEqualTo: [0, 0])
        try compareEncoding(of: 123, withType: Int16.self, isEqualTo: [123, 0])
        try compareEncoding(of: .min, withType: Int16.self, isEqualTo: [0, 128])
        try compareEncoding(of: .max, withType: Int16.self, isEqualTo: [255, 127])
        try compareEncoding(of: -1, withType: Int16.self, isEqualTo: [255, 255])
    }

    func testInt32Encoding() throws {
        try compareEncoding(of: .zero, withType: Int32.self, isEqualTo: [0])
        try compareEncoding(of: -1, withType: Int32.self, isEqualTo: [1])
        try compareEncoding(of: 1, withType: Int32.self, isEqualTo: [2])
        try compareEncoding(of: -2, withType: Int32.self, isEqualTo: [3])
        try compareEncoding(of: 123, withType: Int32.self, isEqualTo: [246, 1])
        /// Min is: `-2147483648`, encoded as `4294967295`
        try compareEncoding(of: .min, withType: Int32.self, isEqualTo: [255, 255, 255, 255, 15]) // The last byte contains 4 bits of data
        /// Max is: `2147483647`, encoded as `4294967294`
        try compareEncoding(of: .max, withType: Int32.self, isEqualTo: [254, 255, 255, 255, 15]) // The last byte contains 4 bits of data

    }

    func testInt64Encoding() throws {
        try compareEncoding(of: 0, withType: Int64.self, isEqualTo: [0])
        try compareEncoding(of: 123, withType: Int64.self, isEqualTo: [246, 1])
        try compareEncoding(of: .max, withType: Int64.self, isEqualTo: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compareEncoding(of: .min, withType: Int64.self, isEqualTo: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compareEncoding(of: -1, withType: Int64.self, isEqualTo: [1])
    }

    func testIntEncoding() throws {
        try compareEncoding(of: 0, withType: Int.self, isEqualTo: [0])
        try compareEncoding(of: 123, withType: Int.self, isEqualTo: [246, 1])
        try compareEncoding(of: .max, withType: Int.self, isEqualTo: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compareEncoding(of: .min, withType: Int.self, isEqualTo: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compareEncoding(of: -1, withType: Int.self, isEqualTo: [1])
    }

    func testUInt8Encoding() throws {
        try compareEncoding(of: .zero, withType: UInt8.self, isEqualTo: [0])
        try compareEncoding(of: 123, withType: UInt8.self, isEqualTo: [123])
        try compareEncoding(of: .min, withType: UInt8.self, isEqualTo: [0])
        try compareEncoding(of: .max, withType: UInt8.self, isEqualTo: [255])
    }

    func testUInt16Encoding() throws {
        try compareEncoding(of: .zero, withType: UInt16.self, isEqualTo: [0, 0])
        try compareEncoding(of: 123, withType: UInt16.self, isEqualTo: [123, 0])
        try compareEncoding(of: .min, withType: UInt16.self, isEqualTo: [0, 0])
        try compareEncoding(of: .max, withType: UInt16.self, isEqualTo: [255, 255])
        try compareEncoding(of: 12345, withType: UInt16.self, isEqualTo: [0x39, 0x30])
    }

    func testUInt32Encoding() throws {
        try compareEncoding(of: .zero, withType: UInt32.self, isEqualTo: [0])
        try compareEncoding(of: 123, withType: UInt32.self, isEqualTo: [123])
        try compareEncoding(of: .min, withType: UInt32.self, isEqualTo: [0])
        try compareEncoding(of: 12345, withType: UInt32.self, isEqualTo: [0xB9, 0x60])
        try compareEncoding(of: 123456, withType: UInt32.self, isEqualTo: [0xC0, 0xC4, 0x07])
        try compareEncoding(of: 12345678, withType: UInt32.self, isEqualTo: [0xCE, 0xC2, 0xF1, 0x05])
        try compareEncoding(of: 1234567890, withType: UInt32.self, isEqualTo: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compareEncoding(of: .max, withType: UInt32.self, isEqualTo: [255, 255, 255, 255, 15]) // The last byte contains 4 bits of data
    }

    func testUInt64Encoding() throws {
        try compareEncoding(of: 0, withType: UInt64.self, isEqualTo: [0])
        try compareEncoding(of: 123, withType: UInt64.self, isEqualTo: [123])
        try compareEncoding(of: .min, withType: UInt64.self, isEqualTo: [0])
        try compareEncoding(of: 12345, withType: UInt64.self, isEqualTo: [0xB9, 0x60])
        try compareEncoding(of: 123456, withType: UInt64.self, isEqualTo: [0xC0, 0xC4, 0x07])
        try compareEncoding(of: 12345678, withType: UInt64.self, isEqualTo: [0xCE, 0xC2, 0xF1, 0x05])
        try compareEncoding(of: 1234567890, withType: UInt64.self, isEqualTo: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compareEncoding(of: 12345678901234, withType: UInt64.self, isEqualTo: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try compareEncoding(of: .max, withType: UInt64.self, isEqualTo: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testUIntEncoding() throws {
        try compareEncoding(of: 0, withType: UInt.self, isEqualTo: [0])
        try compareEncoding(of: 123, withType: UInt.self, isEqualTo: [123])
        try compareEncoding(of: .min, withType: UInt.self, isEqualTo: [0])
        try compareEncoding(of: 12345, withType: UInt.self, isEqualTo: [0xB9, 0x60])
        try compareEncoding(of: 123456, withType: UInt.self, isEqualTo: [0xC0, 0xC4, 0x07])
        try compareEncoding(of: 12345678, withType: UInt.self, isEqualTo: [0xCE, 0xC2, 0xF1, 0x05])
        try compareEncoding(of: 1234567890, withType: UInt.self, isEqualTo: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compareEncoding(of: 12345678901234, withType: UInt.self, isEqualTo: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try compareEncoding(of: .max, withType: UInt.self, isEqualTo: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testStringEncoding() throws {
        try compare("Some", to: Array("Some".data(using: .utf8)!))
        try compare("A longer text with\n multiple lines", to: Array("A longer text with\n multiple lines".data(using: .utf8)!))
        try compare("More text", to: Array("More text".data(using: .utf8)!))
        try compare("eolqjwqu(Jan?!)§(!N", to: Array("eolqjwqu(Jan?!)§(!N".data(using: .utf8)!))
    }

    func testFloatEncoding() throws {
        try compareEncoding(of: .greatestFiniteMagnitude, withType: Float.self, isEqualTo: [0x7F, 0x7F, 0xFF, 0xFF])
        try compareEncoding(of: .zero, withType: Float.self, isEqualTo: [0x00, 0x00, 0x00, 0x00])
        try compareEncoding(of: .pi, withType: Float.self, isEqualTo: [0x40, 0x49, 0x0F, 0xDA])
        try compareEncoding(of: -.pi, withType: Float.self, isEqualTo: [0xC0, 0x49, 0x0F, 0xDA])
        try compareEncoding(of: .leastNonzeroMagnitude, withType: Float.self, isEqualTo: [0x00, 0x00, 0x00, 0x01])
    }

    func testDoubleEncoding() throws {
        try compareEncoding(of: .greatestFiniteMagnitude, withType: Double.self, isEqualTo: [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compareEncoding(of: .zero, withType: Double.self, isEqualTo: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        try compareEncoding(of: .pi, withType: Double.self, isEqualTo: [0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
        try compareEncoding(of: .leastNonzeroMagnitude, withType: Double.self, isEqualTo: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])
        try compareEncoding(of: -.pi, withType: Double.self, isEqualTo: [0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
    }

    func testDataEncoding() throws {
        try compareEncoding(of: Data(), withType: Data.self, isEqualTo: [])
        try compareEncoding(of: Data([0]), withType: Data.self, isEqualTo: [0])
        try compareEncoding(of: Data([0x40, 0x09, 0x21, 0xFB]), withType: Data.self, isEqualTo: [0x40, 0x09, 0x21, 0xFB])
    }
}
