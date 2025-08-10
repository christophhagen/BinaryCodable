import XCTest
import BinaryCodable

final class ContainerTests: XCTestCase {

    /**
     Test that it's possible to create multiple single value containers on the same encoder,
     and that only the last value is saved, regardless of which container is used.
     */
    func testMultipleCallsToSingleContainer() throws {
        struct Test: Codable, Equatable {
            let key: String

            init(key: String) {
                self.key = key
            }

            enum CodingKeys: CodingKey {
                case key
            }

            func encode(to encoder: any Encoder) throws {
                var container1 = encoder.singleValueContainer()
                var container2 = encoder.singleValueContainer()
                try container1.encode("abc")
                try container2.encode(key)
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.key = try container.decode(String.self)
            }
        }

        let value = Test(key: "ABC")
        try compare(value)
    }

    /**
     Test that encoding fails if no calls are made to a single value container.
     */
    func testNoValueEncodedInSingleValueContainer() throws {
        struct Test: Codable, Equatable {
            let key: String

            init(key: String) {
                self.key = key
            }

            func encode(to encoder: any Encoder) throws {
                let _ = encoder.singleValueContainer()
            }
        }

        let value = Test(key: "ABC")
        do {
            _ = try BinaryEncoder().encode(value)
            XCTFail("Should not be able to encode type with unset single value container")
        } catch EncodingError.invalidValue(_, let context) {
            XCTAssertEqual(context.codingPath, [])
            XCTAssertNil(context.underlyingError)
        }
    }

    /**
     Test that multiple keyed containers can be used to encode values
     */
    func testMultipleKeyedContainersForEncoding() throws {
        struct Test: Codable, Equatable {
            let a: String
            let b: String

            func encode(to encoder: any Encoder) throws {
                var container1 = encoder.container(keyedBy: CodingKeys.self)
                var container2 = encoder.container(keyedBy: CodingKeys.self)
                try container1.encode(a, forKey: .a)
                try container2.encode(b, forKey: .b)
            }
        }

        try compare(Test(a: "a", b: "b"))
    }

    /**
     Test that it's possible to encode values from a derived class and the super class
     in the same keyed container.
     */
    func testEncodingSuperAndSubclassInSameKeyedContainer() throws {
        class TestSuper: Codable {
            let a: Int
            init(a: Int) {
                self.a = a
            }
        }

        class TestDerived: TestSuper, Equatable {

            static func == (lhs: TestDerived, rhs: TestDerived) -> Bool {
                lhs.a == rhs.a && lhs.b == rhs.b
            }

            let b: Int

            init(a: Int, b: Int) {
                self.b = b
                super.init(a: a)
            }

            required init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.b = try container.decode(Int.self, forKey: .b)
                try super.init(from: decoder)
            }

            override func encode(to encoder: any Encoder) throws {
                try super.encode(to: encoder)
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(b, forKey: .b)
            }

            enum CodingKeys: CodingKey {
                case b
            }
        }

        let value = TestDerived(a: 123, b: 234)
        let data = try BinaryEncoder().encode(value)
        print(Array(data))

        try compare(value)
    }

    func testUseMultipleKeyedDecoders() throws {
        struct Test: Codable, Equatable {
            let a: Int
            let b: Int

            init(a: Int, b: Int) {
                self.a = a
                self.b = b
            }

            enum CodingKeys1: CodingKey {
                case a
            }

            enum CodingKeys2: CodingKey {
                case b
            }

            init(from decoder: any Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys1.self)
                self.a = try container.decode(Int.self, forKey: .a)
                let container2 = try decoder.container(keyedBy: CodingKeys2.self)
                self.b = try container2.decode(Int.self, forKey: .b)
            }
        }
        try compare(Test(a: 123, b: 234))
    }

    /**
     Test that multiple unkeyed containers on the same node can be used,
     and that they encode values is the order of insertion independent of the container used.
     */
    func testUseMultipleUnkeyedEncoders() throws {
        struct Test: Codable, Equatable {
            let a: Int
            let b: Int

            init(a: Int, b: Int) {
                self.a = a
                self.b = b
            }

            func encode(to encoder: any Encoder) throws {
                var container1 = encoder.unkeyedContainer()
                var container2 = encoder.unkeyedContainer()
                try container2.encode(a)
                try container1.encode(b)
            }

            init(from decoder: any Decoder) throws {
                var container = try decoder.unkeyedContainer()
                self.a = try container.decode(Int.self)
                self.b = try container.decode(Int.self)
            }
        }
        try compare(Test(a: 123, b: 234))
    }
}
