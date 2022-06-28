import XCTest
import BinaryCodable

func compareEncoding<T>(_ type: T.Type, value: T, to expected: [UInt8]) throws where T: Codable, T: Equatable {
    let encoder = BinaryEncoder()
    let data = try encoder.encode(value)
    XCTAssertEqual(Array(data), expected)

    let decoder = BinaryDecoder()
    let decoded = try decoder.decode(T.self, from: data)
    XCTAssertEqual(value, decoded)
}

func compare<T>(_ value: T, to expected: [UInt8]) throws where T: Codable, T: Equatable {
    try compareEncoding(T.self, value: value, to: expected)
}

func compareArray<T>(_ type: T.Type, values: [T], to expected: [UInt8]) throws where T: Codable, T: Equatable {
    try compare(values, to: expected)
}

func compare<T>(_ value: T, possibleResults: [[UInt8]]) throws where T: Codable, T: Equatable {
    let encoder = BinaryEncoder()
    let data = try encoder.encode(value)
    if !possibleResults.contains(Array(data)) {
        XCTFail("\(Array(data)) is not one of the provided options")
    }
    let decoder = BinaryDecoder()
    let decoded = try decoder.decode(T.self, from: data)
    XCTAssertEqual(value, decoded)
}
