import XCTest
import BinaryCodable

final class OptionalEncodingTests: XCTestCase {

    func testArrayOfOptionals() throws {
        let value: [Int?] = [1, nil]
        try compare(value, to: [
            2, // Not nil, length 1
            2, // Int 1
            1 // Nil, length zero
        ])
    }

    func testOptionalBoolEncoding() throws {
        try compare(true, of: Bool?.self, to: [0, 1])
        try compare(false, of: Bool?.self, to: [0, 0])
        try compare(nil, of: Bool?.self, to: [1])
    }

    func testDoubleOptionalBoolEncoding() throws {
        try compare(.some(.some(true)), of: Bool??.self, to: [0, 0, 1])
        try compare(.some(.some(false)), of: Bool??.self, to: [0, 0, 0])
        try compare(.some(.none), of: Bool??.self, to: [0, 1])
        try compare(.none, of: Bool??.self, to: [1])
    }

    func testOptionalStruct() throws {
        struct T: Codable, Equatable {
            var a: Int
        }
        try compare(T(a: 123), of: T?.self, to: [
            0, // Not nil
            3, // String key, length 1
            97, // String "a"
            4, // Length 2
            246, 1 // Int 123
        ])
        try compare(nil, of: T?.self, to: [1])
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
        try compare(Test(value: 123, opt: nil), to: [
            10, // Int key 5
            4, // Length 2
            123, 0 // Int 123
        ])
        let part1: [UInt8] = [
            10, // Int key 5
            4, // Length 2
            123, 0 // value: 123
        ]
        let part2: [UInt8] = [
            8, // Int key 4
            4, // Length 2
            12, 0 // opt: 12
        ]
        try compare(Test(value: 123, opt: 12), toOneOf: [part1 + part2, part2 + part1])
    }
    
    func testDoubleOptional() throws {
        struct Test: Codable, Equatable {
            let opt: Int16??

            enum CodingKeys: Int, CodingKey {
                case opt = 4
            }
        }
        try compare(Test(opt: .some(nil)), to: [
            8, // Int key 4
            1, // nil
        ])
    }

    func testDoubleOptionalInStruct() throws {
        struct Test: Codable, Equatable {
            let value: UInt16

            let opt: Int16??

            enum CodingKeys: Int, CodingKey {
                case value = 5
                case opt = 4
            }
        }
        try compare(Test(value: 123, opt: nil), to: [
            10, // Int key 5
            4, // Length 2
            123, 0 // Int 123
        ])

        let part1: [UInt8] = [
            10, // Int key 5
            4, // Length 2
            123, 0 // value: 123
        ]
        let part2: [UInt8] = [
            8, // Int key 4
            1, // nil
        ]
        try compare(Test(value: 123, opt: .some(nil)), toOneOf: [part1 + part2, part2 + part1])

        let part3: [UInt8] = [
            10, // Int key 5
            4, // Length 2
            123, 0 // value: 123
        ]
        let part4: [UInt8] = [
            8, // Int key 4
            4, // Not nil, Length 2
            12, 0 // value: 12
        ]
        try compare(Test(value: 123, opt: 12), toOneOf: [part3 + part4, part4 + part3])
    }
    
    func testTripleOptionalInStruct() throws {
        struct Test: Codable, Equatable {
            let opt: Int???

            enum CodingKeys: Int, CodingKey {
                case opt = 4
            }
        }
        try compare(Test(opt: nil), to: [])
        
        try compare(Test(opt: .some(nil)), to: [
            8, // Int key 4
            1, // nil
        ])
        
        try compare(Test(opt: .some(.some(nil))), to: [
            8, // Int key 4
            2, // Not nil, length 2
            1, // nil
        ])
        
        try compare(Test(opt: .some(.some(.some(5)))), to: [
            8, // Int key 4
            4, // Not nil, length 2
            0, // Not nil
            10, // Int 10
        ])
    }

    func testClassWithOptionalProperty() throws {
        // NOTE: Here, the field for 'date' is present in the data
        // because the optional is directly encoded using encode()
        // The field for 'partner' is not added, since it's encoded using `encodeIfPresent()`
        let item = TestClass(name: "Bob", date: nil, partner: nil)
        try compare(item, to: [
            2, // Int key 1
            6, // Length 3
            66, 111, 98, // Bob
            4, // Int key 2
            1 // Nil
        ], sortingKeys: true)

        let item2 = TestClass(name: "Bob", date: "s", partner: "Alice")
        try compare(item2, to: [
            2, // Int key 1
            6, // Length 3
            66, 111, 98, // Bob
            4, // Int key 2
            2, // Length 2
            115, // "s"
            6, // Int key 3
            10, // Length 5
            65, 108, 105, 99, 101
        ], sortingKeys: true)
    }
}


private final class TestClass: Codable, Equatable, CustomStringConvertible {
    let name: String
    let date: String?
    let partner: String?

    enum CodingKeys: Int, CodingKey {
        case name = 1
        case date = 2
        case partner = 3
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let date = try container.decode(String?.self, forKey: .date)
        let partner = try container.decodeIfPresent(String.self, forKey: .partner)
        self.init(name: name, date: date, partner: partner)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(partner, forKey: .partner)
    }

    init(name: String, date: String?, partner: String?) {
        self.name = name
        self.date = date
        self.partner = partner
    }

    static func == (lhs: TestClass, rhs: TestClass) -> Bool {
        lhs.name == rhs.name && lhs.date == rhs.date && lhs.partner == rhs.partner
    }

    var description: String {
        "\(name): \(date ?? "nil"), \(partner ?? "nil")"
    }
}
