import XCTest
import BinaryCodable

final class UnkeyedContainerTests: XCTestCase {

    func testCountAndIndexInUnkeyedContainer() throws {
        
        struct Unkeyed: SomeCodable {
            
            static func encode(_ encoder: any Encoder) throws {
                var container = encoder.unkeyedContainer()
                try container.encode(true)
                try container.encode("Some")
                try container.encode(123)
            }
            
            static func decode(_ decoder: any Decoder) throws {
                var container = try decoder.unkeyedContainer()
                if let count = container.count {
                    XCTAssertEqual(count, 3)
                } else {
                    XCTFail("No count in unkeyed container")
                }
                XCTAssertEqual(container.currentIndex, 0)
                XCTAssertEqual(container.isAtEnd, false)

                XCTAssertEqual(try container.decode(Bool.self), true)
                XCTAssertEqual(container.currentIndex, 1)
                XCTAssertEqual(container.isAtEnd, false)

                XCTAssertEqual(try container.decode(String.self), "Some")
                XCTAssertEqual(container.currentIndex, 2)
                XCTAssertEqual(container.isAtEnd, false)

                XCTAssertEqual(try container.decode(Int.self), 123)
                XCTAssertEqual(container.currentIndex, 3)
                XCTAssertEqual(container.isAtEnd, true)
            }
        }
        
        try compare(Unkeyed())
    }

    func testIntSet() throws {
        let value: Set<Int> = [1, 2, 3, 123, Int.max, Int.min]
        try compare(value)
    }

    func testSetOfStructs() throws {
        struct Test: Codable, Hashable {
            let value: String
        }
        let values: Set<Test> = [.init(value: "Some"), .init(value: "More"), .init(value: "Test")]
        try compare(values)
    }

    func testSetOfOptionals() throws {
        let value: Set<Bool?> = [true, false, nil]
        try compare(value)
    }

    func testOptionalSet() throws {
        let value: Set<Bool>? = [true, false]
        try compare(value)

        let value2: Set<Bool>? = nil
        try compare(value2)
    }

}
