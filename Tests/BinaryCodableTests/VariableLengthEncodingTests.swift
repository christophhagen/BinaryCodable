import XCTest
@testable import BinaryCodable

final class VariableLengthEncodingTests: XCTestCase {

    func compare<T>(_ value: T, to result: [UInt8]) throws where T: VariableLengthCodable {
        let data = value.variableLengthEncoding
        XCTAssertEqual(Array(data), result)
        let decoded = try T(fromVarint: data, codingPath: [])
        XCTAssertEqual(decoded, value)
    }

    func testEncodeInt() throws {
        try compare<Int>(0, to: [0])
        try compare<Int>(123, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(Int.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(Int.min, to: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare<Int>(-1, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testEncodeInt32() throws {
        try compare<Int32>(0, to: [0])
        try compare<Int32>(123, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(Int32.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0x07])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(Int32.min, to: [0x80, 0x80, 0x80, 0x80, 0x08])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare<Int32>(Int32(-1), to: [0xFF, 0xFF, 0xFF, 0xFF, 0x0F])
    }

    func testEncodeUInt64() throws {
        func compare(_ value: UInt64, to result: [UInt8]) throws {
            let data = value.encodedData
            XCTAssertEqual(Array(data), result)
            let decoded = try UInt64(data: data, codingPath: [])
            XCTAssertEqual(decoded, value)
        }
        try compare(0, to: [0])
        try compare(123, to: [123])
        try compare(1234, to: [0xD2, 0x09])
        try compare(123456, to: [0xC0, 0xC4, 0x07])
        try compare(1234567890, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare(1234567890123456, to: [0xC0, 0xF5, 0xAA, 0xE4, 0xD3, 0xDA, 0x98, 0x02])
        try compare(.max - 1, to: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compare(.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])

    }
}
