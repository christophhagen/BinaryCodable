import XCTest
@testable import BinaryCodable

final class ArrayEncodingTests: XCTestCase {
 
    func testBoolArrayEncoding() throws {
        try compareArray(Bool.self, values: [true, false, false],
                         to: [1, 0, 0])
    }
    
    func testInt8Encoding() throws {
        try compareArray(Int8.self, values: [.zero, 123, .min, .max, -1],
                         to: [0, 123, 128, 127, 255])
    }
    
    func testInt16Encoding() throws {
        try compareArray(Int16.self, values: [.zero, 123, .min, .max, -1],
                         to: [0, 0, 123, 0, 0, 128, 255, 127, 255, 255])
    }
    
    func testInt32Encoding() throws {
        try compareArray(Int32.self, values: [.zero, 123, .min, .max, -1],
                         to: [0, // 0
                              246, 1, // 123
                              255, 255, 255, 255, 15, // -2.147.483.648
                              254, 255, 255, 255, 15, // 2.147.483.647
                              1]) // -1
    }
    
    func testInt64Encoding() throws {
        try compareArray(Int64.self, values: [0, 123, .max, .min, -1],
                         to: [0, // 0
                              246, 1, // 123
                              0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // max
                              0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // min
                              1]) // 1
    }
    
    func testIntEncoding() throws {
        try compareArray(Int.self, values: [0, 123, .max, .min, -1],
                         to: [0, // 0
                              246, 1, // 123
                              0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // max
                              0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, // min
                              1]) // 1
    }
    
    func testUInt8Encoding() throws {
        try compareArray(UInt8.self, values: [.zero, 123, .min, .max],
                         to: [0, 123, 0, 255])
    }
    
    func testUInt16Encoding() throws {
        try compareArray(UInt16.self, values: [.zero, 123, .min, .max, 12345],
                         to: [0, 0,
                              123, 0,
                              0, 0,
                              255, 255,
                              0x39, 0x30])
    }
    
    func testUInt32Encoding() throws {
        try compareArray(UInt32.self, values: [.zero, 123, .min, 12345, 123456, 12345678, 1234567890, .max],
                         to: [0,
                              123,
                              0,
                              0xB9, 0x60,
                              0xC0, 0xC4, 0x07,
                              0xCE, 0xC2, 0xF1, 0x05,
                              0xD2, 0x85, 0xD8, 0xCC, 0x04,
                              255, 255, 255, 255, 15])
    }
    
    func testUInt64Encoding() throws {
        try compareArray(UInt64.self, values: [.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max],
                         to: [0,
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
        try compareArray(UInt.self, values: [.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max],
                         to: [0,
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
        let values = ["Some", "A longer text with\n multiple lines", "More text", "eolqjwqu(Jan?!)§(!N"]
        let result = values.map { value -> [UInt8] in
            let data = Array(value.data(using: .utf8)!)
            return data.count.variableLengthEncoding + data
        }.reduce([], +)
        try compareArray(String.self, values: values, to: result)
    }
    
    func testFloatEncoding() throws {
        try compareArray(Float.self, values: [.greatestFiniteMagnitude, .zero, .pi, -.pi, .leastNonzeroMagnitude],
                         to: [0x7F, 0x7F, 0xFF, 0xFF,
                              0x00, 0x00, 0x00, 0x00,
                              0x40, 0x49, 0x0F, 0xDA,
                              0xC0, 0x49, 0x0F, 0xDA,
                              0x00, 0x00, 0x00, 0x01])
    }
    
    func testDoubleEncoding() throws {
        try compareArray(Double.self, values: [.greatestFiniteMagnitude, .zero, .pi, .leastNonzeroMagnitude, -.pi],
                         to: [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF,
                              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
                              0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18,
                              0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01,
                              0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
    }
    
    func testArrayOfOptionalsEncoding() throws {
        try compareArray(Bool?.self, values: [true, false, nil, true, nil, false],
                            to: [1, 1, 1, 0, 0, 1, 1, 0, 1, 0])
    }

    func testArrayOfDoubleOptionalsEncoding() throws {
        try compareArray(Bool??.self, values: [.some(.some(true)), .some(.some(false)), .some(.none), .none],
                            to: [1, 1, 1,
                                 1, 1, 0,
                                 1, 0,
                                 0])
    }

    func testArrayOfTripleOptionalsEncoding() throws {
        try compareArray(Bool???.self, values: [.some(.some(.some(true))), .some(.some(.some(false))), .some(.some(.none)), .some(.none), .none],
                            to: [1, 1, 1, 1,
                                 1, 1, 1, 0,
                                 1, 1, 0,
                                 1, 0,
                                 0])
    }
    
    func testArrayOfArraysEncoding() throws {
        let values: [[Bool]] = [[false], [true, false]]
        try compareArray([Bool].self, values: values,
                            to: [1, 0,
                                 2, 1, 0])
    }

    func testDataEncoding() throws {
        let data = Data([1, 2, 3, 0, 255, 123])
        let expected: [UInt8] = [1, 2, 3, 0, 255, 123]
        try compare(data, to: expected)
        try compare(Data(), to: [])
    }

    private func compareWithIndexSet<T>(_ input: T, bytes: [UInt8]) throws where T: Codable, T: Equatable {
        let encoder = BinaryEncoder()
        encoder.prependNilIndexSetForUnkeyedContainers = true
        let decoder = BinaryDecoder()
        decoder.containsNilIndexSetForUnkeyedContainers = true

        let encoded = try encoder.encode(input)
        XCTAssertEqual(encoded.bytes, bytes)
        let decoded = try decoder.decode(T.self, from: encoded)
        XCTAssertEqual(input, decoded)
    }

    func testEncodingWithNilSet() throws {
        try compareWithIndexSet([1,2,3], bytes: [0, 2, 4, 6])
    }

    func testEncodingOptionalsWithNilSet() throws {
        let c = UnkeyedOptionalContainer(values: [1, nil, 2, nil, 3])
        try compareWithIndexSet(c, bytes: [2, 1, 3, 2, 4, 6])
    }
}

private struct UnkeyedOptionalContainer: Equatable {

    let values: [Int?]

}

extension UnkeyedOptionalContainer: Codable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for value in values {
            if let value {
                try container.encode(value)
            } else {
                try container.encodeNil()
            }
        }
    }

    enum CodingKeys: CodingKey {
        case values
    }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var values: [Int?] = []
        while !container.isAtEnd {
            if try container.decodeNil() {
                values.append(nil)
            } else {
                let value = try container.decode(Int.self)
                values.append(value)
            }
        }
        self.values = values
    }
}
