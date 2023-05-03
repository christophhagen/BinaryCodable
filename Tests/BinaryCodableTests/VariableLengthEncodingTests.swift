import XCTest
@testable import BinaryCodable

final class VariableLengthEncodingTests: XCTestCase {
    
    private func rountTrip<T>(_ type: T.Type, value: T) throws where T: Codable, T: VariableLengthCodable, T: Equatable {
        let data = value.variableLengthEncoding
        let decoded = try type.init(fromVarint: data, path: [])
        XCTAssertEqual(decoded, value)
    }
    
    func testEncodeUInt64() {
        func compare(_ value: UInt64, to result: [UInt8]) {
            XCTAssertEqual(Array(value.variableLengthEncoding), result)
        }
        compare(0, to: [0])
        compare(123, to: [123])
        compare(.max, to: .init(repeating: 0xFF, count: 9))
        compare(123456, to: [0xC0, 0xC4, 0x07])
    }
    
    func testEncodeInt() {
        func compare(_ value: Int, to result: [UInt8]) {
            XCTAssertEqual(Array(value.variableLengthEncoding), result)
        }
        compare(0, to: [0])
        compare(123, to: [123])
        // For max, all next-byte bits are set, and all other bits are also set, except for the 63rd
        compare(.max, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0x7F])
        // For min, only the 63rd bit is set, so the first 8 bytes have only the next-byte bit set,
        // and the last byte (which has no next-byte bit, has the highest bit set
        compare(.min, to: [0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80])
        // For -1, all data bits are set, and also all next-byte bits.
        compare(-1, to: [0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF])
    }
    
    func testEncodeDecodeUInt64() throws {
        func roundTrip(_ value: UInt64) throws {
            let data = value.variableLengthEncoding
            let decoded = try UInt64(fromVarint: data, path: [])
            XCTAssertEqual(decoded, value)
        }
        
        try roundTrip(0)
        try roundTrip(.max)
        try roundTrip(.max - 1)
        try roundTrip(123)
        try roundTrip(1234)
        try roundTrip(123456)
        try roundTrip(1234567890)
        try roundTrip(1234567890123456)
    }
}
