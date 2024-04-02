import XCTest
import BinaryCodable

final class StructEncodingTests: XCTestCase {

    func testStructWithArray() throws {
        struct Test: Codable, Equatable {
            let val: [Bool]
        }
        let expected: [UInt8] = [
            7, // String key, length 3
            118, 97, 108,
            12, // Length 6
            2, 1, // true
            2, 0, // false
            2, 1] // true
        try compare(Test(val: [true, false, true]), to: expected)
    }

    func testArrayOfStructs() throws {
        struct Test: Codable, Equatable {
            let val: Int
        }
        let value = [Test(val: 123), Test(val: 124)]
        let expected: [UInt8] = [
            14, // Length 7
            7, // String key, length 3
            118, 97, 108, // 'val'
            4, // Length 2
            246, 1, // Value '123'
            14, // Length 7
            7, // String key, length 3
            118, 97, 108, // 'val'
            4, // Length 2
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
            14, // Not nil, length 7
            7, // String key, length 3
            118, 97, 108, // 'val'
            4, // Length 2
            246, 1, // Value '123'
            1, // Nil
            14, // Not nil, length 7
            7, // String key, length 3
            118, 97, 108, // 'val'
            4, // Length 2
            248, 1, // Value '124'
        ]
        try compare(value, to: expected)
    }

    func testNegativeIntegerKeys() throws {
        struct Test: Codable, Equatable {
            let val: Bool

            enum CodingKeys: Int, CodingKey {
                case val = -1
            }
        }
        let encoder = BinaryEncoder()
        do {
            _ = try encoder.encode(Test(val: true))
        } catch let error as EncodingError {
            guard case .invalidValue(let any, let context) = error else {
                XCTFail()
                return
            }
            XCTAssertEqual(context.codingPath, [-1])
            guard let int = any as? Int else {
                XCTFail()
                return
            }
            XCTAssertEqual(int, -1)
        }
    }

    func testIntegerKeysValidLowerBound() throws {
        struct TestLowBound: Codable, Equatable {
            let val: Bool

            enum CodingKeys: Int, CodingKey {
                case val = 0
            }
        }
        let value = TestLowBound(val: true)
        let expected: [UInt8] = [
            0, // Int key 0
            2, 1, /// Bool `true`
        ]
        try compare(value, to: expected)
    }

    func testIntegerKeysValidUpperBound() throws {
        struct TestUpperBound: Codable, Equatable {
            let val: Bool

            enum CodingKeys: Int, CodingKey {
                case val = 9223372036854775807
            }
        }
        let value = TestUpperBound(val: true)
        let expected: [UInt8] = [
            254, 255, 255, 255, 255, 255, 255, 255, 255, // Int key 9223372036854775807
            2, 1, /// Bool `true`
        ]
        try compare(value, to: expected)
    }

    func testSortingStructKeys() throws {
        struct Test: Codable, Equatable {

            let one: Int

            let two: String

            let three: Bool

            enum CodingKeys: Int, CodingKey {
                case one = 1
                case two = 2
                case three = 3
            }
        }

        let val = Test(one: 123, two: "Some", three: true)
        try compare(val, to: [
            2, // Int key 1
            4, // Length 2
            246, 1, // Int(123)
            4, // Int key 2
            8, // Length 4
            83, 111, 109, 101, // "Some"
            6, // Int key 3
            2, // Length 1
            1, // 'true'
        ], sortingKeys: true)
    }

    func testDecodeDictionaryAsStruct() throws {
        struct Test: Codable, Equatable {
            let a: Int
            let b: Int
            let c: Int
        }

        let input: [String: Int] = ["a" : 123, "b": 0, "c": -123456]
        let encoded = try BinaryEncoder.encode(input)

        let decoded: Test = try BinaryDecoder.decode(from: encoded)
        XCTAssertEqual(decoded, Test(a: 123, b: 0, c: -123456))
    }

    func testDecodeStructAsDictionary() throws {
        struct Test: Codable, Equatable {
            let a: Int
            let b: Int
            let c: Int
        }

        let input = Test(a: 123, b: 0, c: -123456)
        let encoded = try BinaryEncoder.encode(input)

        let decoded: [String: Int] = try BinaryDecoder.decode(from: encoded)
        XCTAssertEqual(decoded, ["a" : 123, "b": 0, "c": -123456])
    }

    func testDecodeKeyedContainerInSingleValueContainer() throws {
        struct Wrapper: Codable, Equatable {
            let wrapped: Wrapped

            init(wrapped: Wrapped) {
                self.wrapped = wrapped
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.wrapped = try container.decode(Wrapped.self)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(wrapped)
            }
        }
        struct Wrapped: Codable, Equatable {
            let val: String
        }

        let expected: [UInt8] = [
            7, // String key, length 3
            118, 97, 108, // "val"
            8, // Length 4
            83, 111, 109, 101, // "Some"
        ]

        let wrapped = Wrapped(val: "Some")
        let encodedWrapped = try BinaryEncoder.encode(wrapped)

        try compare(encodedWrapped, to: expected)

        let decodedWrapped: Wrapped = try BinaryDecoder.decode(from: encodedWrapped)
        XCTAssertEqual(decodedWrapped, wrapped)

        let wrapper = Wrapper(wrapped: wrapped)
        let encodedWrapper = try BinaryEncoder.encode(wrapper)

        // Prepend nil-indicator
        try compare(encodedWrapper, to: [0] + expected)

        let decodedWrapper: Wrapper = try BinaryDecoder.decode(from: encodedWrapper)
        XCTAssertEqual(decodedWrapper, wrapper)
    }
}
