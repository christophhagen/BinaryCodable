import XCTest
import BinaryCodable

final class OptionalEncodingTests: XCTestCase {
    
    func testOptionalBoolEncoding() throws {
        func compare(_ value: Bool?, to expected: [UInt8]) throws {
            try compareEncoding(Bool?.self, value: value, to: expected)
        }
        try compare(true, to: [1])
        try compare(false, to: [0])
        try compare(nil, to: [])
    }
    
    func testArrayOfOptionalsEncoding() throws {
        let value: [Bool?] = [false, nil, true]
        try compareEncoding([Bool?].self, value: value, to: [1, 1, 0, 1])
    }

    func testOptionalInStructEncoding() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            let opt: Int16?

            enum CodingKeys: Int, CodingKey {
                case value = 5
                case opt = 4
            }
        }
        try compare(Test(value: 123, opt: nil), to: [0b01010111, 123, 0])
        let part1: [UInt8] = [0b01000111, 123, 0]
        let part2: [UInt8] = [0b01010111, 123, 0]
        try compare(Test(value: 123, opt: 123), possibleResults: [part1 + part2, part2 + part1])
    }

    func testClassWithOptionalProperty() throws {
        let item = TestClass(withName: "Bob", endDate: nil)

        let data = try BinaryEncoder().encode(item)
        let decoded: TestClass = try BinaryDecoder().decode(from: data)
        XCTAssertEqual(item, decoded)
    }
}


private final class TestClass: Codable, Equatable {
    let name: String
    let date: String?

    enum CodingKeys: String, CodingKey {
        case name
        case date
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let date = try container.decode(String?.self, forKey: .date)
        self.init(withName: name, endDate: date)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(date, forKey: .date)
    }

    init(withName name: String, endDate: String?) {
        self.name = name
        date = endDate
    }

    static func == (lhs: TestClass, rhs: TestClass) -> Bool {
        lhs.name == rhs.name && lhs.date == rhs.date
    }
}
