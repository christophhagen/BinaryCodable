import XCTest
@testable import BinaryCodable

final class ArrayEncodingTests: XCTestCase {

    func testBoolArrayEncoding() throws {
        try compare([true, false, false], to: [
            1, 0, 0
        ])
    }

    func testInt8ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: [Int8].self, to: [
            0, 123, 128, 127, 255
        ])
    }

    func testInt16ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: [Int16].self, to: [
            0, 0,
            123, 0,
            0, 128,
            255, 127,
            255, 255
        ])
    }

    func testInt32ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: [Int32].self, to: [
            0, // 0
            246, 1, // 123
            255, 255, 255, 255, 15, // -2.147.483.648
            254, 255, 255, 255, 15, // 2.147.483.647
            1]) // -1
    }

    func testInt64ArrayEncoding() throws {
        try compare([0, 123, .max, .min, -1], of: [Int64].self, to: [
            0, // 0
            246, 1, // 123
            0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // max
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // min
            1]) // 1
    }

    func testIntArrayEncoding() throws {
        try compare([0, 123, .max, .min, -1], of: [Int].self, to: [
            0, // 0
            246, 1, // 123
            0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // max
            0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // min
            1]) // 1
    }

    func testUInt8ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max], of: [UInt8].self, to: [
            0,
            123,
            0,
            255
        ])
    }

    func testUInt16ArrayEncoding() throws {
        try compare([.zero, 123, .min, .max, 12345], of: [UInt16].self, to: [
            0, 0,
            123, 0,
            0, 0,
            255, 255,
            0x39, 0x30
        ])
    }

    func testUInt32ArrayEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, .max], of: [UInt32].self, to: [
            0,
            123,
            0,
            0xB9, 0x60,
            0xC0, 0xC4, 0x07,
            0xCE, 0xC2, 0xF1, 0x05,
            0xD2, 0x85, 0xD8, 0xCC, 0x04,
            255, 255, 255, 255, 15])
    }

    func testUInt64ArrayEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max], of: [UInt64].self, to: [
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

    func testUIntArrayEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max], of: [UInt].self, to: [
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
            0x7F, 0x7F, 0xFF, 0xFF,
            0x00, 0x00, 0x00, 0x00,
            0x40, 0x49, 0x0F, 0xDA,
            0xC0, 0x49, 0x0F, 0xDA,
            0x00, 0x00, 0x00, 0x01])
    }

    func testDoubleArrayEncoding() throws {
        try compare([.greatestFiniteMagnitude, .zero, .pi, .leastNonzeroMagnitude, -.pi], of: [Double].self, to: [
            0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
            0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18,
            0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
            0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
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
            2, 0,
            4, 1, 0
        ])
    }

    func testDataEncoding() throws {
        let data = Data([1, 2, 3, 0, 255, 123])
        let expected: [UInt8] = [1, 2, 3, 0, 255, 123]
        try compare(data, to: expected)
        try compare(Data(), to: [])
    }
    func testVeryLargePropertyPerformance() throws {
        struct Test: Codable {
            let values: [Float]

            enum CodingKeys: Int, CodingKey {
                case values = 1
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                let data: Data = values.withUnsafeBufferPointer { Data(buffer: $0) }
                try container.encode(data, forKey: .values)
            }

            init(values: [Float]) {
                self.values = values
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let data = try container.decode(Data.self, forKey: .values)
                self.values = data.withUnsafeBytes { Array($0.bindMemory(to: Float.self)) }
            }
        }

        let value = Test(values: .init(repeating: 3.14, count: 1000000))

        self.measure {
            do {
                let _ = try BinaryEncoder.encode(value)
                //print(data.count)
            } catch {
                XCTFail(error.localizedDescription)
            }
        }
    }
}
