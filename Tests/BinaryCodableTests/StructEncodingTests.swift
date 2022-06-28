import XCTest
@testable import BinaryCodable

final class StructEncodingTests: XCTestCase {

    func testStructWithArray() throws {
        struct Test: Codable, Equatable {
            let val: [Bool]
        }
        let expected: [UInt8] = [0b00111010, 118, 97, 108,
                                 4, 0, 1, 0, 1]
        try compare(Test(val: [true, false, true]), to: expected)
    }

    func testArrayOfStructs() throws {
        struct Test: Codable, Equatable {
            let val: Int
        }
        let value = [Test(val: 123), Test(val: 124)]
        let expected: [UInt8] = [
            0, // nil index set
            6, // Length of first element
            0b00111000, 118, 97, 108, // String key 'val', varint
            246, 1, // Value '123'
            6, // Length of second element
            0b00111000, 118, 97, 108, // String key 'val', varint
            248, 1, // Value '124'
        ]
        try compare(value, to: expected)
    }

    func testArrayOfOptionalStructs() throws {
        struct Test: Codable, Equatable {
            let val: Int
        }
        let value: [Test?] = [Test(val: 123), nil, Test(val: 124)]
        let expected: [UInt8] = [
            1, 1, // nil index set
            6, // Length of first element
            0b00111000, 118, 97, 108, // String key 'val', varint
            246, 1, // Value '123'
            6, // Length of third element
            0b00111000, 118, 97, 108, // String key 'val', varint
            248, 1, // Value '124'
        ]
        try compare(value, to: expected)
    }
}
