import XCTest
@testable import BinaryCodable

final class BoolTests: XCTestCase {

    func testBoolAtTopLevel() throws {
        try compare(false, to: [0])
        try compare(true,  to: [1])
    }

    func testOptionalBool() throws {
        try compare(false, of: Bool?.self, to: [0, 0])
        try compare(true, of: Bool?.self,  to: [0, 1])
        try compare(nil, of: Bool?.self,  to: [1])
    }

    func testArrayBool() throws {
        try compare([false], to: [0])
        try compare([true],  to: [1])
        try compare([true, false],  to: [1, 0])
        try compare([false, true],  to: [0, 1])
    }

    func testArrayOptionalBool() throws {
        try compare([false], of: [Bool?].self, to: [2, 0])
        try compare([true], of: [Bool?].self,  to: [2, 1])
        try compare([true, false], of: [Bool?].self,  to: [2, 1, 2, 0])
        try compare([false, true], of: [Bool?].self,  to: [2, 0, 2, 1])
        try compare([nil], of: [Bool?].self, to: [1])
        try compare([nil, nil], of: [Bool?].self, to: [1, 1])
        try compare([false, nil], of: [Bool?].self, to: [2, 0, 1])
        try compare([nil, true], of: [Bool?].self, to: [1, 2, 1])
    }

    func testOptionalArrayBool() throws {
        try compare(nil, of: [Bool]?.self, to: [1])
        try compare([false], of: [Bool]?.self, to: [0, 0])
        try compare([true], of: [Bool]?.self,  to: [0, 1])
        try compare([true, false], of: [Bool]?.self,  to: [0, 1, 0])
        try compare([false, true], of: [Bool]?.self,  to: [0, 0, 1])
    }

    func testDoubleOptionalBool() throws {
        try compare(nil, of: Bool??.self, to: [1])
        try compare(.some(nil), of: Bool??.self, to: [0, 1])
        try compare(true, of: Bool??.self, to: [0, 0, 1])
        try compare(false, of: Bool??.self, to: [0, 0, 0])
    }

    func testTripleOptionalBool() throws {
        try compare(nil, of: Bool???.self, to: [1])
        try compare(.some(nil), of: Bool???.self, to: [0, 1])
        try compare(.some(.some(nil)), of: Bool???.self, to: [0, 0, 1])
        try compare(true, of: Bool???.self, to: [0, 0, 0, 1])
        try compare(false, of: Bool???.self, to: [0, 0, 0, 0])
    }

    func testStructWithBool() throws {
        struct Test: Codable, Equatable {
            let value: Bool
            enum CodingKeys: Int, CodingKey { case value = 1 }
        }

        let expected: [UInt8] = [
            2, // Int key 1 (2x, String bit 0)
            2, // Length of value (2x, Nil bit 0)
            1, // Value
        ]
        try compare(Test(value: true), to: expected)
    }

    func testUnkeyedWithBool() throws {
        
        struct UnkeyedWithBool: SomeCodable {
            
            static func encode(_ encoder: any Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(true)
            }
            
            static func decode(_ decoder: any Decoder) throws {
                var container = try decoder.unkeyedContainer()
                let value = try container.decode(Bool.self)
                XCTAssertEqual(value, true)
            }
        }
        
        try compare(UnkeyedWithBool())
    }
}
