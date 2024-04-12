import XCTest
@testable import BinaryCodable

final class SequenceEncoderTests: XCTestCase {

    private func encodeSequence<T>(_ input: Array<T>) throws where T: Codable, T: Equatable {
        let encoder = BinaryStreamEncoder<T>()

        let bytes = try input.mapAndJoin(encoder.encode)
        print(Array(bytes))
        let decoder = BinaryStreamDecoder<T>()

        decoder.add(bytes)
        let decoded = try decoder.decodeElements()
        XCTAssertEqual(decoded, input)
    }

    func testIntegerEncoding() throws {
        try encodeSequence([1, 2, 3])
        try encodeSequence([1.0, 2.0, 3.0])
        try encodeSequence([true, false, true])
        try encodeSequence(["Some", "Text", "More"])
    }

    func testComplexEncoding() throws {
        struct Test: Codable, Equatable {
            let a: Int
            let b: String
        }
        try encodeSequence([Test(a: 1, b: "Some"), Test(a: 2, b: "Text"), Test(a: 3, b: "More")])
    }

    func testOptionalEncoding() throws {
        try encodeSequence([1, nil, 2, nil, 3])
    }

    func testDecodePartialData() throws {
        struct Test: Codable, Equatable {
            let a: Int
            let b: String
        }
        let input = [Test(a: 1, b: "Some"), Test(a: 2, b: "Text"), Test(a: 3, b: "More")]

        let encoder = BinaryStreamEncoder<Test>()
        let bytes = try encoder.encode(contentsOf: input)

        let decoder = BinaryStreamDecoder<Test>()

        // Provide only the beginning of the stream
        decoder.add(bytes.dropLast(10))
        let first = try decoder.decodeElements()
        // Decode remaining bytes
        decoder.add(bytes.suffix(10))
        let remaining = try decoder.decodeElements()

        XCTAssertEqual(first + remaining, input)
    }

    func testDecodingError() throws {
        struct Test: Codable, Equatable, CustomStringConvertible {
            let a: Int
            let b: String
            var description: String { "\(a),\(b)"}
        }
        let input = [Test(a: 1, b: "Some"), Test(a: 2, b: "Text"), Test(a: 3, b: "More")]

        var enc = BinaryEncoder()
        enc.sortKeysDuringEncoding = true
        let encoder = BinaryStreamEncoder<Test>(encoder: enc)
        var data = try encoder.encode(contentsOf: input)
        // Add invalid byte
        data.insert(123, at: 15)
        let decoder = BinaryStreamDecoder<Test>()

        do {
            decoder.add(data)
            let decoded = try decoder.decodeElements()
            XCTAssertEqual(decoded, input)
            XCTFail("Should not be able to decode \(decoded)")
        } catch is DecodingError {

        }
    }

    func testDecodeUntilError() throws {
        struct Test: Codable, Equatable {
            let a: Int
            let b: String
        }
        let input = [Test(a: 1, b: "Some"), Test(a: 2, b: "Text"), Test(a: 3, b: "More")]

        var enc = BinaryEncoder()
        enc.sortKeysDuringEncoding = true
        let encoder = BinaryStreamEncoder<Test>(encoder: enc)
        var data = try encoder.encode(contentsOf: input)
        // Add invalid byte
        data.insert(123, at: 28)
        let decoder = BinaryStreamDecoder<Test>()

        decoder.add(data)
        let decoded = decoder.decodeElementsUntilError()
        XCTAssertNotNil(decoded.error)
        XCTAssertEqual(decoded.elements, [input[0], input[1]])
    }
}
