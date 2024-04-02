import XCTest
@testable import BinaryCodable

final class ArrayEncodingTests: XCTestCase {

    func testBoolArrayEncoding() throws {
        try compare([true, false, false], to: [
            2, 1,
            2, 0,
            2, 0
        ])
    }

    func testInt8ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: [Int8].self, to: [
            2, 0,
            2, 123,
            2, 128,
            2, 127,
            2, 255
        ])
    }

    func testInt16ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: [Int16].self, to: [
            4, 0, 0,
            4, 123, 0,
            4, 0, 128,
            4, 255, 127,
            4, 255, 255
        ])
    }

    func testInt32ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: [Int32].self, to: [
            2, 0, // 0
            4, 246, 1, // 123
            10, 255, 255, 255, 255, 15, // -2.147.483.648
            10, 254, 255, 255, 255, 15, // 2.147.483.647
            2, 1]) // -1
    }

    func testInt64ArrayEncoding() throws {
        try compare([0, 123, .max, .min, -1], of: [Int64].self, to: [
            2, 0, // 0
            4, 246, 1, // 123
            18, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // max
            18, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // min
            2, 1]) // 1
    }

    func testIntArrayEncoding() throws {
        try compare([0, 123, .max, .min, -1], of: [Int].self, to: [
            2, 0, // 0
            4, 246, 1, // 123
            18, 0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // max
            18, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // min
            2, 1]) // 1
    }

    func testUInt8ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max], of: [UInt8].self, to: [
            2, 0,
            2, 123,
            2, 0,
            2, 255
        ])
    }

    func testUInt16ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, 12345], of: [UInt16].self, to: [
            4, 0, 0,
            4, 123, 0,
            4, 0, 0,
            4, 255, 255,
            4, 0x39, 0x30
        ])
    }

    func testUInt32ArrayEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, .max], of: [UInt32].self, to: [
            2, 0,
            2, 123,
            2, 0,
            4, 0xB9, 0x60,
            6, 0xC0, 0xC4, 0x07,
            8, 0xCE, 0xC2, 0xF1, 0x05,
            10, 0xD2, 0x85, 0xD8, 0xCC, 0x04,
            10, 255, 255, 255, 255, 15])
    }

    func testUInt64ArrayEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max], of: [UInt64].self, to: [
            2, 0,
            2, 123,
            2, 0,
            4, 0xB9, 0x60,
            6, 0xC0, 0xC4, 0x07,
            8, 0xCE, 0xC2, 0xF1, 0x05,
            10, 0xD2, 0x85, 0xD8, 0xCC, 0x04,
            14, 0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02,
            18, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testUIntArrayEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max], of: [UInt].self, to: [
            2, 0,
            2, 123,
            2, 0,
            4, 0xB9, 0x60,
            6, 0xC0, 0xC4, 0x07,
            8, 0xCE, 0xC2, 0xF1, 0x05,
            10, 0xD2, 0x85, 0xD8, 0xCC, 0x04,
            14, 0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02,
            18, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testStringArrayEncoding() throws {
        let values = ["Some", "A longer text with\n multiple lines", "More text", "eolqjwqu(Jan?!)§(!N"]
        let result = values.map { value -> [UInt8] in
            let data = Array(value.data(using: .utf8)!)
            return [UInt8(data.count * 2)] + data
        }.reduce([], +)
        try compare(values, to: result)
    }

    func testFloatArrayEncoding() throws {
        try compare([.greatestFiniteMagnitude, .zero, .pi, -.pi, .leastNonzeroMagnitude], of: [Float].self, to: [
            8, 0x7F, 0x7F, 0xFF, 0xFF,
            8, 0x00, 0x00, 0x00, 0x00,
            8, 0x40, 0x49, 0x0F, 0xDA,
            8, 0xC0, 0x49, 0x0F, 0xDA,
            8, 0x00, 0x00, 0x00, 0x01])
    }

    func testDoubleArrayEncoding() throws {
        try compare([.greatestFiniteMagnitude, .zero, .pi, .leastNonzeroMagnitude, -.pi], of: [Double].self, to: [
            16, 0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            16, 0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18,
            16, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
            16, 0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
    }

    func testArrayOfOptionalsEncoding() throws {
        try compare([true, false, nil, true, nil, false], of: [Bool?].self, to: [
            2, 1,
            2, 0,
            1,
            2, 1,
            1,
            2, 0
        ])
    }

    func testArrayOfDoubleOptionalsEncoding() throws {
        try compare([.some(.some(true)), .some(.some(false)), .some(.none), .none], of: [Bool??].self, to: [
            4, 0, 1,
            4, 0, 0,
            2, 1,
            1])
    }

    func testArrayOfTripleOptionalsEncoding() throws {
        try compare([.some(.some(.some(true))), .some(.some(.some(false))), .some(.some(.none)), .some(.none), .none], of: [Bool???].self, to: [
            6, 0, 0, 1,
            6, 0, 0, 0,
            4, 0, 1,
            2, 1,
            1])
    }

    func testArrayOfArraysEncoding() throws {
        let values: [[Bool]] = [[false], [true, false]]
        try compare(values, of: [[Bool]].self, to: [
            4, 2, 0,
            8, 2, 1, 2, 0
        ])
    }

    func testDataEncoding() throws {
        let data = Data([1, 2, 3, 0, 255, 123])
        let expected: [UInt8] = [1, 2, 3, 0, 255, 123]
        try compare(data, to: expected)
        try compare(Data(), to: [])
    }
}
