import XCTest
@testable import BinaryCodable

/**
 Tests to ensure that coding paths are correctly set.
 */
final class CodingPathTests: XCTestCase {

    func testCodingPathAtRoot() throws {
        struct Root: SomeCodable {

            static func encode(_ encoder: any Encoder) throws {
                // Need to set some value, otherwise encoding will fail
                var container = encoder.singleValueContainer()
                try container.encode(0)
                XCTAssertEqual(encoder.codingPath, [])
            }

            static func decode(_ decoder: any Decoder) throws {
                XCTAssertEqual(decoder.codingPath, [])
            }
        }
        try compare(Root())
    }

    func testCodingPathInKeyedContainer() throws {
        enum SomeKey: Int, CodingKey {
            case value = 1
        }
        
        struct Keyed: SomeCodable {

            static func encode(_ encoder: any Encoder) throws {
                XCTAssertEqual(encoder.codingPath, [])
                var container = encoder.container(keyedBy: SomeKey.self)
                let unkeyed = container.nestedUnkeyedContainer(forKey: .value)
                XCTAssertEqual(unkeyed.codingPath, [1])
            }

            static func decode(_ decoder: any Decoder) throws {
                XCTAssertEqual(decoder.codingPath, [])
                let container = try decoder.container(keyedBy: SomeKey.self)
                let unkeyed = try container.nestedUnkeyedContainer(forKey: .value)
                XCTAssertEqual(unkeyed.codingPath, [1])
            }
        }
        try compare(Keyed())
    }
}
