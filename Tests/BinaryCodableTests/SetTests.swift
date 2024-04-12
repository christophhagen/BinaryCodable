import XCTest
import BinaryCodable

final class SetTests: XCTestCase {

    func testBoolSetEncoding() throws {
        try compare([true, false], of: Set<Bool>.self, to: [
            1, 0
        ])
    }

    func testInt8SetEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: Set<Int8>.self)
        try compare([-1], of: Set<Int8>.self, to: [255])
    }

    func testInt16SetEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: Set<Int16>.self)
        try compare([-1], of: Set<Int16>.self, to: [255, 255])
    }

    func testInt32SetEncoding() throws {
        try compare([.zero, 123, .min, .max, -1], of: Set<Int32>.self)
        try compare([-1], of: Set<Int32>.self, to: [1])
    }

    func testInt64SetEncoding() throws {
        try compare([0, 123, .max, .min, -1], of: Set<Int64>.self)
        try compare([-1], of: Set<Int64>.self, to: [1])
    }

    func testIntSetEncoding() throws {
        try compare([0, 123, .max, .min, -1], of: Set<Int>.self)
        try compare([0], of: Set<Int>.self, to: [0])
        try compare([123], of: Set<Int>.self, to: [246, 1])
        try compare([.max], of: Set<Int>.self, to: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compare([.min], of: Set<Int>.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compare([-1], of: Set<Int>.self, to: [1]) // 1
    }

    func testUInt8SetEncoding() throws {
        try compare([.zero, 123, .min, .max], of: Set<UInt8>.self)
        try compare([.zero], of: Set<UInt8>.self, to: [0])
        try compare([123], of: Set<UInt8>.self, to: [123])
        try compare([.min], of: Set<UInt8>.self, to: [0])
        try compare([.max], of: Set<UInt8>.self, to: [255])
    }

    func testUInt16SetEncoding() throws {
        try compare([.zero, 123, .min, .max, 12345], of: Set<UInt16>.self)
        try compare([.zero], of: Set<UInt16>.self, to: [0, 0])
        try compare([123], of: Set<UInt16>.self, to: [123, 0])
        try compare([.min], of: Set<UInt16>.self, to: [0, 0])
        try compare([.max], of: Set<UInt16>.self, to: [255, 255])
        try compare([12345], of: Set<UInt16>.self, to: [0x39, 0x30])
    }

    func testUInt32SetEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, .max], of: Set<UInt32>.self)

        try compare([.zero], of: Set<UInt32>.self, to: [0])
        try compare([123], of: Set<UInt32>.self, to: [123])
        try compare([.min], of: Set<UInt32>.self, to: [0])
        try compare([12345], of: Set<UInt32>.self, to: [0xB9, 0x60])
        try compare([123456], of: Set<UInt32>.self, to: [0xC0, 0xC4, 0x07])
        try compare([12345678], of: Set<UInt32>.self, to: [0xCE, 0xC2, 0xF1, 0x05])
        try compare([1234567890], of: Set<UInt32>.self, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare([.max], of: Set<UInt32>.self, to: [255, 255, 255, 255, 15])
    }

    func testUInt64SetEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max], of: Set<UInt64>.self)

        try compare([.zero], of: Set<UInt64>.self, to: [0])
        try compare([123], of: Set<UInt64>.self, to: [123])
        try compare([.min], of: Set<UInt64>.self, to: [0])
        try compare([12345], of: Set<UInt64>.self, to: [0xB9, 0x60])
        try compare([123456], of: Set<UInt64>.self, to: [0xC0, 0xC4, 0x07])
        try compare([12345678], of: Set<UInt64>.self, to: [0xCE, 0xC2, 0xF1, 0x05])
        try compare([1234567890], of: Set<UInt64>.self, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare([12345678901234], of: Set<UInt64>.self, to: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try compare([.max], of: Set<UInt64>.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testUIntSetEncoding() throws {
        try compare([.zero, 123, .min, 12345, 123456, 12345678, 1234567890, 12345678901234, .max], of: Set<UInt>.self)

        try compare([.zero], of: Set<UInt>.self, to: [0])
        try compare([123], of: Set<UInt>.self, to: [123])
        try compare([.min], of: Set<UInt>.self, to: [0])
        try compare([12345], of: Set<UInt>.self, to: [0xB9, 0x60])
        try compare([123456], of: Set<UInt>.self, to: [0xC0, 0xC4, 0x07])
        try compare([12345678], of: Set<UInt>.self, to: [0xCE, 0xC2, 0xF1, 0x05])
        try compare([1234567890], of: Set<UInt>.self, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare([12345678901234], of: Set<UInt>.self, to: [0xF2, 0xDF, 0xB8, 0x9E, 0xA7, 0xE7, 0x02])
        try compare([.max], of: Set<UInt>.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testStringSetEncoding() throws {
        let values1 = ["Some"]
        try compare(values1, to: [
            8, // Length 4
            83, 111, 109, 101 // "Some"
        ])

        let values2: Set<String> = ["Some", "A longer text with\n multiple lines", "More text", "eolqjwqu(Jan?!)§(!N"]
        try compare(values2)
    }

    func testFloatSetEncoding() throws {
        try compare([.greatestFiniteMagnitude, .zero, .pi, -.pi, .leastNonzeroMagnitude], of: Set<Float>.self)
        try compare([.greatestFiniteMagnitude], of: Set<Float>.self, to: [0x7F, 0x7F, 0xFF, 0xFF])
        try compare([.zero], of: Set<Float>.self, to: [0x00, 0x00, 0x00, 0x00])
        try compare([.pi], of: Set<Float>.self, to: [0x40, 0x49, 0x0F, 0xDA])
        try compare([-.pi], of: Set<Float>.self, to: [0xC0, 0x49, 0x0F, 0xDA])
        try compare([.leastNonzeroMagnitude], of: Set<Float>.self, to: [0x00, 0x00, 0x00, 0x01])
    }

    func testDoubleSetEncoding() throws {
        try compare([.greatestFiniteMagnitude, .zero, .pi, .leastNonzeroMagnitude, -.pi], of: Set<Double>.self)

        try compare([.greatestFiniteMagnitude], of: Set<Double>.self, to: [0x7F, 0xEF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compare([.zero], of: Set<Double>.self, to: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        try compare([.pi], of: Set<Double>.self, to: [0x40, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
        try compare([.leastNonzeroMagnitude], of: Set<Double>.self, to: [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01])
        try compare([-.pi], of: Set<Double>.self, to: [0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18])
    }

    func testSetOfOptionalsEncoding() throws {
        try compare([true, false, nil], of: Set<Bool?>.self)
    }

    func testSetOfDoubleOptionalsEncoding() throws {
        try compare([.some(.some(true)), .some(.some(false)), .some(.none), .none], of: Set<Bool??>.self)
    }

    func testSetOfTripleOptionalsEncoding() throws {
        try compare([.some(.some(.some(true))), .some(.some(.some(false))), .some(.some(.none)), .some(.none), .none], of: Set<Bool???>.self)
    }

    func testSetOfSetsEncoding() throws {
        let values: Set<Set<Bool>> = [[false], [true, false]]
        try compare(values, of: Set<Set<Bool>>.self)
    }

}
