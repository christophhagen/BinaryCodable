import XCTest
import BinaryCodable

func compareEncoding<T>(_ type: T.Type, value: T, to expected: [UInt8]) throws where T: Codable {
    let encoder = BinaryEncoder()
    let data = try encoder.encode(value)
    XCTAssertEqual(Array(data), expected)
}

func compare<T>(_ value: T, to expected: [UInt8]) throws where T: Codable {
    try compareEncoding(T.self, value: value, to: expected)
}

func compareArray<T>(_ type: T.Type, values: [T], to expected: [UInt8]) throws where T: Codable, T: Equatable {
    try compare(values, to: expected)
}

func compare<T>(_ value: T, possibleResults: [[UInt8]]) throws where T: Codable {
    let encoder = BinaryEncoder()
    let data = try Array(encoder.encode(value))
    if possibleResults.contains(data) {
        return
    }
    XCTFail("\(data) is not one of the provided options")
}

func compareDecoding<T>(_ type: T.Type, value: T, from data: [UInt8]) throws where T: Codable, T: Equatable {
    let decoder = BinaryDecoder()
    let decoded = try decoder.decode(T.self, from: Data(data))
    XCTAssertEqual(value, decoded)
}
