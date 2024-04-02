import XCTest
@testable import BinaryCodable

final class UUIDEncodingTests: XCTestCase {

    func testUUID() throws {
        let id = UUID(uuidString: "D0829408-FA77-4511-ACFC-21504DE16CE1")!
        // Add nil indicator
        let expected = [0] + Array(id.uuidString.data(using: .utf8)!)
        try compare(id, to: expected)
    }

    func testEnumWithUUID() throws {
        let id = UUID(uuidString: "D0829408-FA77-4511-ACFC-21504DE16CE1")!
        let value = UUIDContainer.test(id)
        let expected = [9, // String key, length 4
                        116, 101, 115, 116, // "test"
                        80, // Length 40
                        5, // String key, length 2
                        95, 48,  // "_0"
                        72] // Length of UUID
        + Array(id.uuidString.data(using: .utf8)!)
        try compare(value, to: expected)
    }

}

private enum UUIDContainer: Codable, Equatable {
    case test(UUID)
}
