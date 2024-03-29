import XCTest
@testable import BinaryCodable

/**
 Tests to ensure that coding paths are correctly set.
 */
final class CodingPathTests: XCTestCase {

    func testCodingPathAtRoot() throws {
        GenericTestStruct.encode { encoder in
            // Need to set some value, otherwise encoding will fail
            var container = encoder.singleValueContainer()
            try container.encode(0)
            XCTAssertEqual(encoder.codingPath, [])
        }
        GenericTestStruct.decode { decoder in
            XCTAssertEqual(decoder.codingPath, [])
        }
        try compare(GenericTestStruct())
    }

    func testCodingPathInKeyedContainer() throws {
        enum SomeKey: Int, CodingKey {
            case value = 1
        }
        GenericTestStruct.encode { encoder in
            XCTAssertEqual(encoder.codingPath, [])
            var container = encoder.container(keyedBy: SomeKey.self)
            let unkeyed = container.nestedUnkeyedContainer(forKey: .value)
            XCTAssertEqual(unkeyed.codingPath, [1])
        }
        GenericTestStruct.decode { decoder in
            XCTAssertEqual(decoder.codingPath, [])
            let container = try decoder.container(keyedBy: SomeKey.self)
            let unkeyed = try container.nestedUnkeyedContainer(forKey: .value)
            XCTAssertEqual(unkeyed.codingPath, [1])
        }
        try compare(GenericTestStruct())
    }
}
