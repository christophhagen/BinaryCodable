import XCTest
@testable import BinaryCodable

final class OptionalEncodingTests: XCTestCase {
    
    func testOptionalBoolEncoding() throws {
        func compare(_ value: Bool?, to expected: [UInt8]) throws {
            try compareEncoding(Bool?.self, value: value, to: expected)
        }
        try compare(true, to: [1, 1])
        try compare(false, to: [1, 0])
        try compare(nil, to: [0])
        let encoder = BinaryEncoder()
        let value: Bool? = nil
        try encoder.printTree(value)
    }
    
    func testArrayOfOptionalsEncoding() throws {
        let value: [Bool?] = [false, nil, true]
        try BinaryEncoder().printTree(value)
        try compareEncoding([Bool?].self, value: value, to: [1, 1, 0, 1])
    }
}
