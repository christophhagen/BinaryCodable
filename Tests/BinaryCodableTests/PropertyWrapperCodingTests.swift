import XCTest
import BinaryCodable

/// While from the perspective of `Codable` nothing about property wrapper is special,
/// they tend to encode their values via `singleValueContainer()`, which requires
/// some considerations when it comes to dealing with optionals.
///
final class PropertyWrapperCodingTests: XCTestCase {
    struct KeyedWrapper<T: Codable & Equatable>: Codable, Equatable {
        enum CodingKeys: String, CodingKey {
            case wrapper
        }

        @Wrapper
        var value: T

        init(_ value: T) {
            self._value = Wrapper(wrappedValue: value)
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self._value = try container.decode(Wrapper<T>.self, forKey: .wrapper)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(_value, forKey: .wrapper)
        }
    }

    @propertyWrapper
    struct Wrapper<T: Codable & Equatable>: Codable, Equatable {
        let wrappedValue: T

        init(wrappedValue: T) {
            self.wrappedValue = wrappedValue
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.wrappedValue = try container.decode(T.self)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(wrappedValue)
        }
    }

    struct WrappedString: Codable, Equatable {
        let val: String
    }

    func assert<T: Codable & Equatable>(
        encoding wrapped: T,
        as type: T.Type = T.self,
        expectByteSuffix byteSuffix: [UInt8],
        file: StaticString = #file,
        line: UInt = #line
    ) throws {
        let bytePrefix: [UInt8] = [
            15, // String key, length 7
            119, 114, 97, 112, 112, 101, 114, // "wrapper"
        ]

        let wrapper = KeyedWrapper<T>(wrapped)
        let data = try BinaryEncoder.encode(wrapper)

        // If the prefix differs, this error affects the test helper, so report it here
        XCTAssertEqual(Array(data.prefix(bytePrefix.count)), bytePrefix)

        // If the suffix differs, this error is specific to the individual test case,
        // so report it on the call-side
        XCTAssertEqual(Array(data.suffix(from: bytePrefix.count)), byteSuffix, file: (file), line: line)

        let decodedWrapper: KeyedWrapper<T> = try BinaryDecoder.decode(from: data)
        XCTAssertEqual(decodedWrapper, wrapper, file: (file), line: line)
    }

    func testOptionalWrappedStringSome() throws {
        try assert(
            encoding: WrappedString(val: "Some"),
            as: WrappedString?.self,
            expectByteSuffix: [
                20, // Length 10
                0, // Non-nil
                7, // String key, length 3
                118, 97, 108, // "val"
                8, // Length 4,
                83, 111, 109, 101, // String "Some"
            ]
        )
    }

    func testOptionalWrappedStringNone() throws {
        try assert(
            encoding: nil,
            as: WrappedString?.self,
            expectByteSuffix: [
                2, // Length 1
                1, // Nil indicator
            ]
        )
    }

    func testOptionalBool() throws {
        try assert(
            encoding: .some(true),
            as: Bool?.self,
            expectByteSuffix: [
                4, // Length 2
                0, // Non-nil
                1, // Boolean is true
            ]
        )

        try assert(
            encoding: .some(false),
            as: Bool?.self,
            expectByteSuffix: [
                4, // Length 2
                0, // Non-nil
                0, // Boolean is false
            ]
        )

        try assert(
            encoding: nil,
            as: Bool?.self,
            expectByteSuffix: [
                2, // Length 1
                1, // Nil
            ]
        )
    }

    func testDoubleOptionalBool() throws {
        try assert(
            encoding: .some(.some(true)),
            as: Bool??.self,
            expectByteSuffix: [
                6, // Length 3
                0, // Not nil
                0, // Not nil
                1 // true
            ]
        )

        try assert(
            encoding: .some(.some(false)),
            as: Bool??.self,
            expectByteSuffix: [
                6, // Length 3
                0, // Not nil
                0, // Not nil
                0 // false
            ]
        )

        try assert(
            encoding: .some(nil),
            as: Bool??.self,
            expectByteSuffix: [
                4, // Length 2
                0, // Not nil
                1 // Nil
            ]
        )

        try assert(
            encoding: nil,
            as: Bool??.self,
            expectByteSuffix: [
                2, // Length 1
                1 // Nil
            ]
        )
    }
}
