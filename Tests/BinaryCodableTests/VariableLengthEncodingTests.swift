import XCTest
@testable import BinaryCodable

final class VariableLengthEncodingTests: XCTestCase {

    func compare<T>(varInt value: T, to result: [UInt8]) throws where T: VariableLengthCodable {
        let data = value.variableLengthEncoding
        XCTAssertEqual(Array(data), result)
        let decoded = try T(fromVarint: data, codingPath: [])
        XCTAssertEqual(decoded, value)
    }

    func testEncodeInt() throws {
        try compare<Int>(varInt: 0, to: [0])
        try compare<Int>(varInt: 123, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(varInt: Int.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(varInt: Int.min, to: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare<Int>(varInt: -1, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }

    func testEncodeInt32() throws {
        try compare<Int32>(varInt: 0, to: [0])
        try compare<Int32>(varInt: 123, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        try compare(varInt: Int32.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0x07])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        try compare(varInt: Int32.min, to: [0x80, 0x80, 0x80, 0x80, 0x08])
        // For -1, all data bits are set, and also all next-byte bits.
        try compare<Int32>(varInt: Int32(-1), to: [0xFF, 0xFF, 0xFF, 0xFF, 0x0F])
    }

    func testEncodeUInt64() throws {
        try compare<UInt64>(varInt: 0, to: [0])
        try compare<UInt64>(varInt: 123, to: [123])
        try compare<UInt64>(varInt: 1234, to: [0xD2, 0x09])
        try compare<UInt64>(varInt: 123456, to: [0xC0, 0xC4, 0x07])
        try compare<UInt64>(varInt: 1234567890, to: [0xD2, 0x85, 0xD8, 0xCC, 0x04])
        try compare<UInt64>(varInt: 1234567890123456, to: [0xC0, 0xF5, 0xAA, 0xE4, 0xD3, 0xDA, 0x98, 0x02])
        try compare<UInt64>(varInt: UInt64.max - 1, to: [0xFE, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
        try compare<UInt64>(varInt: UInt64.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
}
