import XCTest
import BinaryCodable

final class OptionalEncodingTests: XCTestCase {

    func testSingleOptional() throws {
        let value: [Int?] = [1, nil]
        try compare(value, to: [1, 2, 0])
    }
    
    func testOptionalBoolEncoding() throws {
        try compareEncoding(Bool?.self, value: true, to: [1, 1])
        try compareEncoding(Bool?.self, value: false, to: [1, 0])
        try compareEncoding(Bool?.self, value: nil, to: [0])
    }

    func testOptionalStruct() throws {
        struct T: Codable, Equatable {
            var a: Int
        }
        try compareEncoding(T?.self, value: T(a: 123),
                            to: [1, 4, 24, 97, 246, 1])
        try compareEncoding(T?.self, value: nil, to: [0])
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
        // Note: `encodeNil()` is not called for single optionals
        try compare(Test(value: 123, opt: nil), to: [0b01010111, 123, 0])
        let part1: [UInt8] = [0b01010111, 123, 0] // value: 123
        let part2: [UInt8] = [0b01000111, 12, 0] // opt: 12
        try compare(Test(value: 123, opt: 12), possibleResults: [part1 + part2, part2 + part1])
    }

    func testDoubleOptionalInStruct() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            let opt: Int16??

            enum CodingKeys: Int, CodingKey {
                case value = 4
                case opt = 5
            }
        }
        try compare(Test(value: 123, opt: nil), to: [0b01000111, 123, 0])
        let part1: [UInt8] = [0b01000111, 123, 0]
        let part2: [UInt8] = [0b01010010, 3, 1, 12, 0] // Optionals are VarLen
        try compare(Test(value: 123, opt: 12), possibleResults: [part1 + part2, part2 + part1])
    }

    func testClassWithOptionalProperty() throws {
        let item = TestClass(withName: "Bob", endDate: "s")

        let data = try BinaryEncoder().encode(item)
        let decoded: TestClass = try BinaryDecoder().decode(from: data)
        XCTAssertEqual(item, decoded)
    }
}


private final class TestClass: Codable, Equatable, CustomStringConvertible {
    let name: String
    let date: String?

    enum CodingKeys: Int, CodingKey {
        case name = 1
        case date = 2
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

    var description: String {
        "\(name): \(date ?? "nil")"
    }
}
