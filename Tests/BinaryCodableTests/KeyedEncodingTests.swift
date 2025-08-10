import XCTest
@testable import BinaryCodable

private struct Test<T>: Codable, Equatable where T: Codable, T: Equatable {
    let value: T
}

final class KeyedEncodingTests: XCTestCase {

    func testEncodingWithVarintType() throws {
        let expected: [UInt8] = [
            11, // String key, length 5
            118, 97, 108, 117, 101, // String "value"
            4, // length 2
            246, 1] // Int 123
        try compare(Test(value: 123), to: expected)
    }

    func testEncodingWithByteType() throws {
        let expected: [UInt8] = [
            11, // String key, length 5
            118, 97, 108, 117, 101, // String "value"
            2, // length 1
            1] // UInt8(1)
        try compare(Test<UInt8>(value: 1), to: expected)
    }

    func testEncodingWithTwoByteType() throws {
        let expected: [UInt8] = [
            11, // String key, length 5
            118, 97, 108, 117, 101, // String "value"
            4, // length 2
            0xD2, 0x04] // 1234
        try compare(Test<Int16>(value: 1234), to: expected)
    }

    func testEncodingWithVariableLengthType() throws {
        let expected: [UInt8] = [
            11, // String key, length 5
            118, 97, 108, 117, 101, // String "value"
            10, // length 5
            118, 97, 108, 117, 101]
        try compare(Test<String>(value: "value"), to: expected)
    }

    func testEncodingWithFourByteType() throws {
        let expected: [UInt8] = [
            11, // String key, length 5
            118, 97, 108, 117, 101, // String "value"
            8, // length 4
            0x40, 0x49, 0x0F, 0xDA]
        try compare(Test<Float>(value: .pi), to: expected)
    }

    func testEncodingWithEightByteType() throws {
        let expected: [UInt8] = [
            11, // String key, length 5
            118, 97, 108, 117, 101, // String "value"
            16, // length 8
            0xC0, 0x09, 0x21, 0xFB, 0x54, 0x44, 0x2D, 0x18]
        try compare(Test<Double>(value: -.pi), to: expected)
    }

    func testStructEncodingIntegerKey() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            enum CodingKeys: Int, CodingKey {
                case value = 5
            }
        }
        let expected: [UInt8] = [
            10, // Int key 5
            4, // length 2
            123, 0]
        try compare(Test(value: 123), to: expected)
    }

    func testStructEncodingLargeIntegerKey() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            enum CodingKeys: Int, CodingKey {
                case value = 5318273
            }
        }
        let expected: [UInt8] = [
            130, 154, 137, 5, // Int key 5318273
            4, // length 2
            123, 0]
        try compare(Test(value: 123), to: expected)
    }

    func testStringDictEncoding() throws {
        // Dictionaries with string keys are treated as keyed containers
        let value: [String : UInt8] = ["val": 123, "more": 124]
        let part1: [UInt8] = [
            7, // String key, length 3
            118, 97, 108, // String "val"
            2,  // Length 1
            123] // 123
        let part2: [UInt8] = [
            9, // String key, length 4
            109, 111, 114, 101, // String "more"
            2, // Length 1
            124]
        try compare(value, toOneOf: [part1 + part2, part2 + part1])
    }

    func testSortingStringDictEncoding() throws {
        // Dictionaries with string keys are treated as keyed containers
        let value: [String : UInt8] = ["val": 123, "more": 124]
        let part1: [UInt8] = [
            7, // String key, length 3
            118, 97, 108, // String "val"
            2,  // Length 1
            123] // 123
        let part2: [UInt8] = [
            9, // String key, length 4
            109, 111, 114, 101, // String "more"
            2, // Length 1
            124]
        try compare(value, to: part2 + part1, sortingKeys: true)
    }

    func testMixedStringIntegerKeyedDictionary() throws {
        // Strings which can be converted to integers are encoded as such
        // So the string "0" is actually encoded as Int key(0)
        let value: [String : UInt8] = ["val": 123, "0": 124]
        let part1: [UInt8] = [
            7, // String key, length 3
            118, 97, 108, // String "val"
            2,  // Length 1
            123] // 123
        let part2: [UInt8] = [
            0, // Int key 0
            2,  // Length 1
            124] // 124
        try compare(value, toOneOf: [part1 + part2, part2 + part1])
    }

    func testIntDictEncoding() throws {
        // Dictionaries with int keys are treated as keyed containers
        let value: [Int : UInt8] = [123: 123, 124: 124]
        let part1: [UInt8] = [
            246, 1, // Int key 123
            2, // Length 1
            123]
        let part2: [UInt8] = [
            248, 1, // Int key 124
            2, // Length 1
            124]
        try compare(value, toOneOf: [part1 + part2, part2 + part1])
    }

    func testSortingIntDictEncoding() throws {
        // Dictionaries with int keys are treated as keyed containers
        let value: [Int : UInt8] = [123: 123, 124: 124, 125: 125, 126: 126]
        try compare(value, to: [
            246, 1, 2, 123,
            248, 1, 2, 124,
            250, 1, 2, 125,
            252, 1, 2, 126
        ], sortingKeys: true)
    }

    func testUIntDictEncoding() throws {
        // Other dictionaries (keys not int/string) are treated as unkeyed containers of key-value pairs
        let value: [UInt : UInt8] = [123: 123, 124: 124]
        let part1: [UInt8] = [
            2, // Length 1
            123,
            2, // Length 1
            123
        ]
        let part2: [UInt8] = [
            2, // Length 1
            124,
            2, // Length 1
            124
        ]
        try compare(value, toOneOf: [part1 + part2, part2 + part1])
    }

    func testExplicitlyEncodeNil() throws {
        enum Keys: Int, CodingKey {
            case value = 1
            case opt = 2
        }
        GenericTestStruct.encode { encoder in
            var container = encoder.container(keyedBy: Keys.self)
            let value: String? = nil
            try container.encodeIfPresent(value, forKey: .value)
            try container.encodeNil(forKey: .opt)
        }
        GenericTestStruct.decode { decoder in
            let container = try decoder.container(keyedBy: Keys.self)
            XCTAssertFalse(container.contains(.value))
            // Nil is not encoded
            XCTAssertFalse(container.contains(.opt))

            let s = try container.decodeIfPresent(String.self, forKey: .value)
            XCTAssertEqual(s, nil)

            let optIsNil = try container.decodeNil(forKey: .opt)
            XCTAssertTrue(optIsNil)
            let opt = try container.decodeIfPresent(Bool.self, forKey: .opt)
            XCTAssertNil(opt)
            do {
                _ = try container.decode(Bool.self, forKey: .opt)
                XCTFail()
            } catch {

            }
        }
        try compare(GenericTestStruct(), to: [])
    }

    /**
     Check that assigning to the same key twice saves the second value.
     Also check that it's possible to read the same key multiple times.
     */
    func testAssigningAndReadKeyTwice() throws {
        struct TestStruct: Codable, Equatable {
            let key: String

            init(key: String) {
                self.key = key
            }

            enum CodingKeys: CodingKey {
                case key
            }

            func encode(to encoder: any Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode("ABC", forKey: .key)
                try container.encode(key, forKey: .key)
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let _ = try container.decode(String.self, forKey: .key)
                self.key = try container.decode(String.self, forKey: .key)
            }
        }

        try compare(TestStruct(key: "abc"))
    }
}
