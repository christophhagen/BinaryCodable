import XCTest
@testable import BinaryCodable

private class Base: Codable {

    let value: Int

    init(value: Int) {
        self.value = value
    }

    enum CodingKeys: Int, CodingKey {
        case value = 1
    }
}

private class Child1: Base {

    let other: Bool

    init(other: Bool, value: Int) {
        self.other = other
        super.init(value: value)
    }

    enum CodingKeys: Int, CodingKey {
        case other = 2
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.other = try container.decode(Bool.self, forKey: .other)
        let superDecoder = try container.superDecoder()
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(other, forKey: .other)
        let superEncoder = container.superEncoder()
        try super.encode(to: superEncoder)
    }
}

extension Child1: Equatable {
    static func == (lhs: Child1, rhs: Child1) -> Bool {
        lhs.other == rhs.other && lhs.value == rhs.value
    }
}

private class Child2: Base {

    let other: Bool

    init(other: Bool, value: Int) {
        self.other = other
        super.init(value: value)
    }

    enum CodingKeys: Int, CodingKey {
        case other = 2
        case `super` = 3
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.other = try container.decode(Bool.self, forKey: .other)
        let superDecoder = try container.superDecoder(forKey: .super)
        try super.init(from: superDecoder)
    }

    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(other, forKey: .other)
        let superEncoder = container.superEncoder(forKey: .super)
        try super.encode(to: superEncoder)
    }
}

extension Child2: Equatable {
    static func == (lhs: Child2, rhs: Child2) -> Bool {
        lhs.other == rhs.other && lhs.value == rhs.value
    }
}

final class SuperEncodingTests: XCTestCase {

    func testSuperEncodingWithDefaultKey() throws {
        let value = Child1(other: true, value: 123)
        let part1: [UInt8] = [
            4, // Int key 2
            2, // Length 1
            1, // Bool true
        ]
        let part2: [UInt8] = [
            0, // Int key 0
            8, // Length 4
            2, // Int key 1
            4, // Length 2
            246, 1, // ZigZag(123)
        ]
        try compare(value, toOneOf: [part1 + part2, part2 + part1])
    }

    func testSuperEncodingWithCustomKey() throws {
        let value = Child2(other: true, value: 123)
        let part1: [UInt8] = [
            4, // Int key 2
            2, // Length 1
            1, // Bool true
        ]
        let part2: [UInt8] = [
            6, // Int key 3
            8, // Length 4
            2, // Int key 1
            4, // Length 2
            246, 1, // ZigZag(123)
        ]
        try compare(value, toOneOf: [part1 + part2, part2 + part1])
    }

    func testInheritance() throws {
        class ParentClass: Codable {
            var text: String = ""
        }

        final class ChildClass: ParentClass, Equatable {
            static func == (lhs: ChildClass, rhs: ChildClass) -> Bool {
                lhs.text == rhs.text && lhs.image == rhs.image
            }

            var image: Data?

            enum CodingKeys: String, CodingKey {
                case image
            }

            override init() {
                self.image = nil
                super.init()
            }

            required init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.image = try container.decodeIfPresent(Data.self, forKey: .image)
                try super.init(from: decoder)
            }

            override func encode(to encoder: any Encoder) throws {
                try super.encode(to: encoder)
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encodeIfPresent(image, forKey: .image)
            }
        }

        let child = ChildClass()
        child.image = Data(repeating: 42, count: 42)

        try compare(child)
    }
}
