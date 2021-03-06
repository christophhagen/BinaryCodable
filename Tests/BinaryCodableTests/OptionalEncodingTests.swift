import XCTest
import BinaryCodable

final class OptionalEncodingTests: XCTestCase {
    
    func testOptionalBoolEncoding() throws {
        func compare(_ value: Bool?, to expected: [UInt8]) throws {
            try compareEncoding(Bool?.self, value: value, to: expected)
        }
        try compare(true, to: [1])
        try compare(false, to: [0])
        try compare(nil, to: [])
    }
    
    func testArrayOfOptionalsEncoding() throws {
        let value: [Bool?] = [false, nil, true]
        try compareEncoding([Bool?].self, value: value, to: [1, 1, 0, 1])
    }

    func testOptionalInStructEncoding() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            let opt: Int16?

            enum CodingKeys: Int, CodingKey {
                case value = 5
                case opt = 4
            }
        }
        try compare(Test(value: 123, opt: nil), to: [0b01010111, 123, 0])
        let part1: [UInt8] = [0b01000111, 123, 0]
        let part2: [UInt8] = [0b01010111, 123, 0]
        try compare(Test(value: 123, opt: 123), possibleResults: [part1 + part2, part2 + part1])
    }
}
