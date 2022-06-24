import XCTest
@testable import BinaryCodable

final class ArrayEncodingTests: XCTestCase {
    
    private func compareEncoding<T>(_ type: T.Type, values: [T], to expected: [UInt8]) throws where T: Codable, T: Equatable {
        let encoder = BinaryEncoder()
        let data = try encoder.encode(values)
        XCTAssertEqual(Array(data), expected)
    }
    
    func testBoolArrayEncoding() throws {
        func compare(_ values: [Bool], to expected: [UInt8]) throws {
            try compareEncoding(Bool.self, values: values, to: expected)
        }
        try compare([true, false, false], to: [0, 1, 0, 0])
        try compare([false, true, true], to: [0, 0, 1, 1])
    }
    
    func testInt8Encoding() throws {
        func compare(_ values: [Int8], to expected: [UInt8]) throws {
            try compareEncoding(Int8.self, values: values, to: expected)
        }
        try compare([.zero, 123, .min, .max, -1],
                    to: [0,
                         0,
                         123,
                         128,
                         127,
                         255])
    }
    
    func testInt16Encoding() throws {
        func compare(_ values: [Int16], to expected: [UInt8]) throws {
            try compareEncoding(Int16.self, values: values, to: expected)
        }
        try compare([.zero, 123, .min, .max, -1],
                    to: [0,
                         0, 0,
                         123, 0,
                         0, 128,
                         255, 127,
                         255, 255])
    }
    
    func testInt32Encoding() throws {
        func compare(_ values: [Int32], to expected: [UInt8]) throws {
            try compareEncoding(Int32.self, values: values, to: expected)
        }
        try compare([.zero, 123, .min, .max, -1],
                    to: [0,
                         0,
                         123,
                         128, 128, 128, 128, 8,
                         255, 255, 255, 255, 7,
                         255, 255, 255, 255, 15])
    }
    
    func testInt64Encoding() throws {
        func compare(_ values: [Int64], to expected: [UInt8]) throws {
            try compareEncoding(Int64.self, values: values, to: expected)
        }
        try compare([0, 123, .max, .min, -1],
                    to: [0,
                         0,
                         123,
                         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F,
                         0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
                         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testIntEncoding() throws {
        func compare(_ values: [Int], to expected: [UInt8]) throws {
            try compareEncoding(Int.self, values: values, to: expected)
        }
        try compare([0, 123, .max, .min, -1],
                    to: [0,
                         0,
                         123,
                         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F,
                         0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80,
                         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testUInt8Encoding() throws {
        func compare(_ values: [UInt8], to expected: [UInt8]) throws {
            try compareEncoding(UInt8.self, values: values, to: expected)
        }
        try compare([.zero, 123, .min, .max],
                    to: [0, 0, 123, 0, 255])
    }
    
    func testUInt16Encoding() throws {
        func compare(_ values: [UInt16], to expected: [UInt8]) throws {
            try compareEncoding(UInt16.self, values: values, to: expected)
        }
        try compare([.zero, 123, .min, .max, 12345],
                    to: [0,
                         0, 0,
                         123, 0,
                         0, 0,
                         255, 255,
                         0x39, 0x30])
    }
    
    func testUInt32Encoding() throws {
        func compare(_ values: [UInt32], to expected: [UInt8]) throws {
            try compareEncoding(UInt32.self, values: values, to: expected)
        }
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, .max],
                    to: [0, 0,
                         123,
                         0,
                         0xB9, 0x60,
                         0xC0, 0xC4, 0x07,
                         0xCE, 0xC2, 0xF1, 0x05,
                         0xD2, 0x85, 0xD8, 0xCC, 0x04,
                         255, 255, 255, 255, 15])
    }
    
    func testUInt64Encoding() throws {
        func compare(_ values: [UInt64], to expected: [UInt8]) throws {
            try compareEncoding(UInt64.self, values: values, to: expected)
        }
        try compare([0, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max],
                    to: [0,
                         0,
                         123,
                         0,
                         0xB9, 0x60,
                         0xC0, 0xC4, 0x07,
                         0xCE, 0xC2, 0xF1, 0x05,
                         0xD2, 0x85, 0xD8, 0xCC, 0x04,
                         0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02,
                         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testUIntEncoding() throws {
        func compare(_ values: [UInt], to expected: [UInt8]) throws {
            try compareEncoding(UInt.self, values: values, to: expected)
        }
        try compare([0, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max],
                    to: [0,
                         0,
                         123,
                         0,
                         0xB9, 0x60,
                         0xC0, 0xC4, 0x07,
                         0xCE, 0xC2, 0xF1, 0x05,
                         0xD2, 0x85, 0xD8, 0xCC, 0x04,
                         0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02,
                         0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testStringEncoding() throws {
        func compare(_ values: [String]) throws {
            let result = [0] + values.map { value -> [UInt8] in
                let data = Array(value.data(using: .utf8)!)
                return data.count.variableLengthEncoding + data
            }.reduce([], +)
            try compareEncoding(String.self, values: values, to: result)
        }
        try compare(["Some", "A longer text with\n multiple lines", "More text", "eolqjwqu(Jan?!)§(!N"])
    }
    
    func testFloatEncoding() throws {
        func compare(_ values: [Float], to expected: [UInt8]) throws {
            try compareEncoding(Float.self, values: values, to: expected)
        }
        try compare([.greatestFiniteMagnitude, .nan, .zero, .pi, -.pi, .leastNonzeroMagnitude],
                    to: [0,
                         0x7F, 0x7F, 0xFF, 0xFF,
                         0x7f, 0xC0, 0x00, 0x00,
                         0x00, 0x00, 0x00, 0x00,
                         0x40, 0x49, 0x0F, 0xDA,
                         0xC0, 0x49, 0x0F, 0xDA,
                         0x00, 0x00, 0x00, 0x01])
    }
    
    func testDoubleEncoding() throws {
        func compare(_ values: [Double], to expected: [UInt8]) throws {
            try compareEncoding(Double.self, values: values, to: expected)
        }
        try compare([.greatestFiniteMagnitude, .zero, .pi, .leastNonzeroMagnitude, -.pi],
                    to: [0,
                         0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                         0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18,
                         0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
                         0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
    }
    
    func testArrayOfOptionalsEncoding() throws {
        try compareEncoding(Bool?.self, values: [true, false, nil, true, nil, false],
                            to: [2, 2, 4,
                                 1, 0, 1, 0])
    }
    
    func testArrayOfArraysEncoding() throws {
        let values: [[Bool]] = [[false], [true, false]]
        try BinaryEncoder().printTree(values)
        try compareEncoding([Bool].self, values: values,
                            to: [0,
                                 2, 0, 0,
                                 3, 0, 1, 0])
    }
}
