import XCTest
import BinaryCodable

final class PrimitiveDecodingTests: XCTestCase {

    func testBoolDecoding() throws {
        func decode(_ value: Bool, from encoded: [UInt8]) throws {
            try compareDecoding(Bool.self, value: value, from: encoded)
        }
        try decode(true, from: [1])
        try decode(false, from: [0])
    }

    func testInt8Decoding() throws {
        func decode(_ value: Int8, from encoded: [UInt8]) throws {
            try compareDecoding(Int8.self, value: value, from: encoded)
        }
        try decode(.zero, from: [0])
        try decode(123, from: [123])
        try decode(.min, from: [128])
        try decode(.max, from: [127])
        try decode(-1, from: [255])
    }

    func testInt16Decoding() throws {
        func decode(_ value: Int16, from encoded: [UInt8]) throws {
            try compareDecoding(Int16.self, value: value, from: encoded)
        }
        try decode(.zero, from: [0, 0])
        try decode(123, from: [123, 0])
        try decode(.min, from: [0, 128])
        try decode(.max, from: [255, 127])
        try decode(-1, from: [255, 255])
    }

    func testInt32Decoding() throws {
        func decode(_ value: Int32, from encoded: [UInt8]) throws {
            try compareDecoding(Int32.self, value: value, from: encoded)
        }
        try decode(.zero, from: [0])
        try decode(123, from: [123])
        try decode(.min, from: [128, 128, 128, 128, 8]) // The last byte contains 4 bits of data
        try decode(.max, from: [255, 255, 255, 255, 7]) // The last byte contains 4 bits of data
        try decode(-1, from: [255, 255, 255, 255, 15]) // The last byte contains 4 bits of data
    }

    func testInt64Decoding() throws {
        func decode(_ value: Int64, from encoded: [UInt8]) throws {
            try compareDecoding(Int64.self, value: value, from: encoded)
        }
        try decode(0, from: [0])
        try decode(123, from: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try decode(.max, from: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try decode(.min, from: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        try decode(-1, from: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testIntDecoding() throws {
        func decode(_ value: Int, from encoded: [UInt8]) throws {
            try compareDecoding(Int.self, value: value, from: encoded)
        }
        try decode(0, from: [0])
        try decode(123, from: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try decode(.max, from: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try decode(.min, from: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        try decode(-1, from: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testUInt8Decoding() throws {
        func decode(_ value: UInt8, from encoded: [UInt8]) throws {
            try compareDecoding(UInt8.self, value: value, from: encoded)
        }
        try decode(.zero, from: [0])
        try decode(123, from: [123])
        try decode(.min, from: [0])
        try decode(.max, from: [255])
    }

    func testUInt16Decoding() throws {
        func decode(_ value: UInt16, from encoded: [UInt8]) throws {
            try compareDecoding(UInt16.self, value: value, from: encoded)
        }
        try decode(.zero, from: [0, 0])
        try decode(123, from: [123, 0])
        try decode(.min, from: [0, 0])
        try decode(.max, from: [255, 255])
        try decode(12345, from: [0x39, 0x30])
    }

    func testUInt32Decoding() throws {
        func decode(_ value: UInt32, from encoded: [UInt8]) throws {
            try compareDecoding(UInt32.self, value: value, from: encoded)
        }
        try decode(.zero, from: [0])
        try decode(123, from: [123])
        try decode(.min, from: [0])
        try decode(12345, from: [0xB9, 0x60])
        try decode(123456, from: [0xC0, 0xC4, 0x07])
        try decode(12345678, from: [0xCE, 0xC2, 0xF1, 0x05])
        try decode(1234567890, from: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try decode(.max, from: [255, 255, 255, 255, 15]) // The last byte contains 4 bits of data
    }

    func testUInt64Decoding() throws {
        func decode(_ value: UInt64, from encoded: [UInt8]) throws {
            try compareDecoding(UInt64.self, value: value, from: encoded)
        }
        try decode(0, from: [0])
        try decode(123, from: [123])
        try decode(.min, from: [0])
        try decode(12345, from: [0xB9, 0x60])
        try decode(123456, from: [0xC0, 0xC4, 0x07])
        try decode(12345678, from: [0xCE, 0xC2, 0xF1, 0x05])
        try decode(1234567890, from: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try decode(12345678901234, from: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try decode(.max, from: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testUIntDecoding() throws {
        func decode(_ value: UInt, from encoded: [UInt8]) throws {
            try compareDecoding(UInt.self, value: value, from: encoded)
        }
        try decode(0, from: [0])
        try decode(123, from: [123])
        try decode(.min, from: [0])
        try decode(12345, from: [0xB9, 0x60])
        try decode(123456, from: [0xC0, 0xC4, 0x07])
        try decode(12345678, from: [0xCE, 0xC2, 0xF1, 0x05])
        try decode(1234567890, from: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try decode(12345678901234, from: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try decode(.max, from: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testStringDecoding() throws {
        func decode(_ value: String) throws {
            try compareDecoding(String.self, value: value, from: Array(value.data(using: .utf8)!))
        }
        try decode("Some")
        try decode("A longer text with\n multiple lines")
        try decode("More text")
        try decode("eolqjwqu(Jan?!)§(!N")
    }

    func testFloatDecoding() throws {
        func decode(_ value: Float, from encoded: [UInt8]) throws {
            try compareDecoding(Float.self, value: value, from: encoded)
        }
        try decode(.greatestFiniteMagnitude, from: [0x7F, 0x7F, 0xFF, 0xFF])
        /// `nan` == `nan` always compares to `false`
        //try decode(.nan, from: [0x7f, 0xC0, 0x00, 0x00])
        try decode(.zero, from: [0x00, 0x00, 0x00, 0x00])
        try decode(.pi, from: [0x40, 0x49, 0x0F, 0xDA])
        try decode(-.pi, from: [0xC0, 0x49, 0x0F, 0xDA])
        try decode(.leastNonzeroMagnitude, from: [0x00, 0x00, 0x00, 0x01])
    }

    func testDoubleDecoding() throws {
        func decode(_ value: Double, from encoded: [UInt8]) throws {
            try compareDecoding(Double.self, value: value, from: encoded)
        }
        print(-Double.pi)
        try decode(.greatestFiniteMagnitude, from: [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try decode(.zero, from: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        try decode(.pi, from: [0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
        try decode(.leastNonzeroMagnitude, from: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])
        try decode(-.pi, from: [0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
    }
}
