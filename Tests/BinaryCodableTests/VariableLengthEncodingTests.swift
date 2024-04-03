import XCTest
@testable import BinaryCodable

final class VariableLengthEncodingTests: XCTestCase {

    func compare<T>(varInt value: T, of: T.Type, to result: [UInt8]) throws where T: VariableLengthCodable {
        let data = value.variableLengthEncoding
        XCTAssertEqual(Array(data), result)
        let decoded = try T(fromVarint: data)
        XCTAssertEqual(decoded, value)
    }

    func testEncodeInt() throws {
        try compare(varInt: 0, of: Int.self, to: [0])
        try compare(varInt: 123, of: Int.self, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(varInt: .max, of: Int.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(varInt: .min, of: Int.self, to: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare(varInt: -1, of: Int.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testEncodeInt32() throws {
        try compare(varInt: 0, of: Int32.self, to: [0])
        try compare(varInt: 123, of: Int32.self, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(varInt: .max, of: Int32.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0x07])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(varInt: .min, of: Int32.self, to: [0x80, 0x80, 0x80, 0x80, 0x08])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare(varInt: -1, of: Int32.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0x0F])
    }

    func testEncodeUInt64() throws {
        try compare(varInt: 0, of: UInt64.self, to: [0])
        try compare(varInt: 123, of: UInt64.self, to: [123])
        try compare(varInt: 1234, of: UInt64.self, to: [0xD2, 0x09])
        try compare(varInt: 123456, of: UInt64.self, to: [0xC0, 0xC4, 0x07])
        try compare(varInt: 1234567890, of: UInt64.self, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare(varInt: 1234567890123456, of: UInt64.self, to: [0xC0, 0xF5, 0xAA, 0xE4, 0xD3, 0xDA, 0x98, 0x02])
        try compare(varInt: .max - 1, of: UInt64.self, to: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compare(varInt: .max, of: UInt64.self, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
}
