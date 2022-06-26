import XCTest
@testable import BinaryCodable

final class PrimitiveEncodingTests: XCTestCase {
    
    func testBoolEncoding() throws {
        func compare(_ value: Bool, to expected: [UInt8]) throws {
            try compareEncoding(Bool.self, value: value, to: expected)
        }
        try compare(true, to: [1])
        try compare(false, to: [0])
    }
    
    func testInt8Encoding() throws {
        func compare(_ value: Int8, to expected: [UInt8]) throws {
            try compareEncoding(Int8.self, value: value, to: expected)
        }
        try compare(.zero, to: [0])
        try compare(123, to: [123])
        try compare(.min, to: [128])
        try compare(.max, to: [127])
        try compare(-1, to: [255])
    }
    
    func testInt16Encoding() throws {
        func compare(_ value: Int16, to expected: [UInt8]) throws {
            try compareEncoding(Int16.self, value: value, to: expected)
        }
        try compare(.zero, to: [0, 0])
        try compare(123, to: [123, 0])
        try compare(.min, to: [0, 128])
        try compare(.max, to: [255, 127])
        try compare(-1, to: [255, 255])
    }
    
    func testInt32Encoding() throws {
        func compare(_ value: Int32, to expected: [UInt8]) throws {
            try compareEncoding(Int32.self, value: value, to: expected)
        }
        try compare(.zero, to: [0])
        try compare(123, to: [123])
        try compare(.min, to: [128, 128, 128, 128, 8]) // The last byte contains 4 bits of data
        try compare(.max, to: [255, 255, 255, 255, 7]) // The last byte contains 4 bits of data
        try compare(-1, to: [255, 255, 255, 255, 15]) // The last byte contains 4 bits of data
    }
    
    func testInt64Encoding() throws {
        func compare(_ value: Int64, to expected: [UInt8]) throws {
            try compareEncoding(Int64.self, value: value, to: expected)
        }
        try compare(0, to: [0])
        try compare(123, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(.min, to: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare(-1, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testIntEncoding() throws {
        func compare(_ value: Int, to expected: [UInt8]) throws {
            try compareEncoding(Int.self, value: value, to: expected)
        }
        try compare(0, to: [0])
        try compare(123, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(.min, to: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare(-1, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testUInt8Encoding() throws {
        func compare(_ value: UInt8, to expected: [UInt8]) throws {
            try compareEncoding(UInt8.self, value: value, to: expected)
        }
        try compare(.zero, to: [0])
        try compare(123, to: [123])
        try compare(.min, to: [0])
        try compare(.max, to: [255])
    }
    
    func testUInt16Encoding() throws {
        func compare(_ value: UInt16, to expected: [UInt8]) throws {
            try compareEncoding(UInt16.self, value: value, to: expected)
        }
        try compare(.zero, to: [0, 0])
        try compare(123, to: [123, 0])
        try compare(.min, to: [0, 0])
        try compare(.max, to: [255, 255])
        try compare(12345, to: [0x39, 0x30])
    }
    
    func testUInt32Encoding() throws {
        func compare(_ value: UInt32, to expected: [UInt8]) throws {
            try compareEncoding(UInt32.self, value: value, to: expected)
        }
        try compare(.zero, to: [0])
        try compare(123, to: [123])
        try compare(.min, to: [0])
        try compare(12345, to: [0xB9, 0x60])
        try compare(123456, to: [0xC0, 0xC4, 0x07])
        try compare(12345678, to: [0xCE, 0xC2, 0xF1, 0x05])
        try compare(1234567890, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare(.max, to: [255, 255, 255, 255, 15]) // The last byte contains 4 bits of data
    }
    
    func testUInt64Encoding() throws {
        func compare(_ value: UInt64, to expected: [UInt8]) throws {
            try compareEncoding(UInt64.self, value: value, to: expected)
        }
        try compare(0, to: [0])
        try compare(123, to: [123])
        try compare(.min, to: [0])
        try compare(12345, to: [0xB9, 0x60])
        try compare(123456, to: [0xC0, 0xC4, 0x07])
        try compare(12345678, to: [0xCE, 0xC2, 0xF1, 0x05])
        try compare(1234567890, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare(12345678901234, to: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try compare(.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testUIntEncoding() throws {
        func compare(_ value: UInt, to expected: [UInt8]) throws {
            try compareEncoding(UInt.self, value: value, to: expected)
        }
        try compare(0, to: [0])
        try compare(123, to: [123])
        try compare(.min, to: [0])
        try compare(12345, to: [0xB9, 0x60])
        try compare(123456, to: [0xC0, 0xC4, 0x07])
        try compare(12345678, to: [0xCE, 0xC2, 0xF1, 0x05])
        try compare(1234567890, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare(12345678901234, to: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try compare(.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testStringEncoding() throws {
        func compare(_ value: String) throws {
            try compareEncoding(String.self, value: value, to: Array(value.data(using: .utf8)!))
        }
        try compare("Some")
        try compare("A longer text with\n multiple lines")
        try compare("More text")
        try compare("eolqjwqu(Jan?!)§(!N")
    }
    
    func testFloatEncoding() throws {
        func compare(_ value: Float, to expected: [UInt8]) throws {
            try compareEncoding(Float.self, value: value, to: expected)
        }
        try compare(.greatestFiniteMagnitude, to: [0x7F, 0x7F, 0xFF, 0xFF])
        try compare(.nan, to: [0x7f, 0xC0, 0x00, 0x00])
        try compare(.zero, to: [0x00, 0x00, 0x00, 0x00])
        try compare(.pi, to: [0x40, 0x49, 0x0F, 0xDA])
        try compare(-.pi, to: [0xC0, 0x49, 0x0F, 0xDA])
        try compare(.leastNonzeroMagnitude, to: [0x00, 0x00, 0x00, 0x01])
    }
    
    func testDoubleEncoding() throws {
        func compare(_ value: Double, to expected: [UInt8]) throws {
            try compareEncoding(Double.self, value: value, to: expected)
        }
        print(-Double.pi)
        try compare(.greatestFiniteMagnitude, to: [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compare(.zero, to: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        try compare(.pi, to: [0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
        try compare(.leastNonzeroMagnitude, to: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])
        try compare(-.pi, to: [0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
    }
}
