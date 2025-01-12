import Foundation
import XCTest
@testable import BinaryCodable

func XCTAssertEqual(_ path: [CodingKey], _ other: [DecodingKey]) {
    let convertedPath = path.map { DecodingKey(key: $0) }
    XCTAssertEqual(convertedPath, other)
}


extension XCTestCase {

    func compare<T>(_ value: T, of type: T.Type = T.self, toOneOf possibleEncodings: [[UInt8]]) throws where T: Codable, T: Equatable {
        let encoder = BinaryEncoder()
        let data = try encoder.encode(value)
        let bytes = Array(data)
        if !possibleEncodings.contains(bytes) {
            XCTFail("Encoded data is: \(bytes), allowed options: \(possibleEncodings)")
        }
        let decoder = BinaryDecoder()
        let decoded = try decoder.decode(T.self, from: data)
        XCTAssertEqual(decoded, value)
    }

    func compare<T>(_ value: T, of type: T.Type = T.self, to expected: [UInt8]? = nil, sortingKeys: Bool = false) throws where T: Codable, T: Equatable {
        var encoder = BinaryEncoder()
        if sortingKeys {
            encoder.sortKeysDuringEncoding = true
        }
        let data = try encoder.encode(value)
        if let expected {
            XCTAssertEqual(Array(data), expected)
        } else {
            print("Encoded data: \(Array(data))")
        }

        let decoder = BinaryDecoder()
        let decoded = try decoder.decode(T.self, from: data)
        XCTAssertEqual(value, decoded)
    }

    func compareEncoding<T>(of value: T, withType type: T.Type = T.self, isEqualTo expected: [UInt8]) throws where T: EncodablePrimitive, T: DecodablePrimitive, T: Equatable {
        let encoded = value.encodedData
        XCTAssertEqual(Array(encoded), expected)
        let decoded = try T.init(data: encoded)
        XCTAssertEqual(decoded, value)
    }
}
