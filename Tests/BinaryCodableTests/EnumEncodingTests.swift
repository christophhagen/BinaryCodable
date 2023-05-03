import XCTest
import BinaryCodable

final class EnumEncodingTests: XCTestCase {

    func testEnumEncoding() throws {
        enum Test: Codable, Equatable {
            case one
            case two
        }
        let expected1: [UInt8] = [
            0b00111010, /// `String` key, length `3`
            111, 110, 101, /// String key `one`
            0 /// Encodes `0` as the `value`
        ]
        try compare(Test.one, to: expected1)

        let expected2: [UInt8] = [
            0b00111010, /// `String` key, length `3`
            116, 119, 111, /// String key `one`
            0 /// Encodes `0` as the `value`
        ]
        try compare(Test.two, to: expected2)
    }

    func testIntEnumEncoding() throws {
        enum Test: Int, Codable, Equatable {
            case one = 1
            case two = 2
        }
        try compare(Test.one, to: [2])
        try compare(Test.two, to: [4])
    }

    func testStringEnumEncoding() throws {
        enum Test: String, Codable, Equatable {
            case one = "one"
            case two = "two"
        }
        try compare(Test.one, to: [111, 110, 101])
        try compare(Test.two, to: [116, 119, 111])
    }
    
    func testEnumWithAssociatedValues() throws {
        /**
         Note: `Codable` encoded associated values using the string keys `_0`, `_1`, ...
         This depends on the number of associated values
         */
        enum Test: Codable, Equatable {
            
            case one(String)
            case two(Int)
            case three(Data)
            case four(Bool)
            case five(UInt, Int8)
        }
        try compare(Test.one("Some"), to: [
            0b00111010, // String key(3), VarLen
            111, 110, 101, // String "one"
            8, // Length 8
            42, // String key(2), VarLen
            95, 48, // String "_0"
            4, // Length 4
            83, 111, 109, 101 // String "Some"
        ])
        try compare(Test.two(123), to: [
            0b00111010, // String key(3), VarLen
            116, 119, 111, // String "two"
            5, // Length 5
            40, // String key(2), VarInt
            95, 48,  // String "_0"
            246, 1 // Int(123)
        ])
        try compare(Test.three(.init(repeating: 42, count: 3)), to: [
            0b01011010, // String key(5), VarLen
            116, 104, 114, 101, 101, // String "three"
            7, // Length 7
            42, // String key, VarLen, length 2
            95, 48,  // String "_0"
            3, // Length 2
            42, 42, 42 // Data(42, 42, 42)
        ])
        
        try compare(Test.four(true), to: [
            0b01001010, // String key(4), VarLen
            102, 111, 117, 114, // String "four"
            4, // Length 4
            40, // String key(2), VarInt
            95, 48,  // String "_0"
            1 // Bool(true)
        ])
        
        let start: [UInt8] = [
            0b01001010, // String key(4), VarLen
            102, 105, 118, 101, // String "five"
            8] // Length 8
        let a: [UInt8] = [
            46, // String key(2), Byte
            95, 49, // String "_1"
            133] // Int8(-123)
        let b: [UInt8] = [
            40, // String key(2), VarInt
            95, 48, // String "_0"
            123] // UInt(123)
        try compare(Test.five(123, -123), possibleResults: [start + a + b, start + b + a])
        
        struct Wrap: Codable, Equatable {
            
            let value: Test
            
            enum CodingKeys: Int, CodingKey {
                case value = 1
            }
        }
        
        try compare(Wrap(value: .four(true)), to: [
            0b00010010, // Int key(1), VarLen
            10, // Length 10
            0b01001010, // String key, VarLen, length 4
            102, 111, 117, 114, // String "four"
            4, // Length 4
            40, // String key(2), VarInt
            95, 48,  // String "_0"
            1 // Bool(true)
        ])
    }
    
    func testEnumWithAssociatedValuesAndIntegerKeys() throws {
        enum Test: Codable, Equatable {
            
            case one(String)
            case two(Int)
            case three(Data)
            case four(Bool)
            case five(UInt, Int8)
            
            enum CodingKeys: Int, CodingKey {
                case one = 1
                case two = 2
                case three = 3
                case four = 4
                case five = 5
            }
        }
        
        try compare(Test.one("Some"), to: [
            0b00010010, // Int key(1), VarLen
            8, // Length 8
            42, // String key(2), VarLen
            95, 48, // String "_0"
            4, // Length 4
            83, 111, 109, 101 // String "Some"
        ])
        try compare(Test.two(123), to: [
            0b00100010, // Int key(2), VarLen
            5, // Length 5
            40, // String key(2), VarInt
            95, 48,  // String "_0"
            246, 1 // Int(123)
        ])
        try compare(Test.three(.init(repeating: 42, count: 3)), to: [
            0b00110010, // Int key(3), VarLen
            7, // Length 7
            42, // String key, VarLen, length 2
            95, 48,  // String "_0"
            3, // Length 2
            42, 42, 42 // Data(42, 42, 42)
        ])
        
        try compare(Test.four(true), to: [
            0b01000010, // Int key(4), VarLen
            4, // Length 4
            40, // String key(2), VarInt
            95, 48,  // String "_0"
            1 // Bool(true)
        ])
        
        let start: [UInt8] = [
            0b01010010, // Int key(5), VarLen
            8] // Length 8
        let a: [UInt8] = [
            46, // String key(2), Byte
            95, 49, // String "_1"
            133] // Int8(-123)
        let b: [UInt8] = [
            40, // String key(2), VarInt
            95, 48, // String "_0"
            123] // UInt(123)
        try compare(Test.five(123, -123), possibleResults: [start + a + b, start + b + a])
    }
    
    func testDecodeUnknownCase() throws {
        enum Test: Int, Codable {
            case one // No raw value assigns 0
        }
        
        try compare(Test.one, to: [0])
        
        let decoder = BinaryDecoder()
        do {
            _ = try decoder.decode(Test.self, from: Data([1]))
            XCTFail("Enum decoding should fail for unknown case")
        } catch DecodingError.dataCorrupted(_) {
            // Correct error
        }
    }
}
