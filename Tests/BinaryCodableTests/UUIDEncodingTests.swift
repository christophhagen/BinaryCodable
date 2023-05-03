import XCTest
@testable import BinaryCodable

final class UUIDEncodingTests: XCTestCase {

    func testUUID() throws {
        let id = UUID(uuidString: "D0829408-FA77-4511-ACFC-21504DE16CE1")!
        let expected = Array(id.uuidString.data(using: .utf8)!)
        try compare(id, to: expected)
    }

    func testEnumWithUUID() throws {
        let id = UUID(uuidString: "D0829408-FA77-4511-ACFC-21504DE16CE1")!
        let value = UUIDContainer.test(id)
        let expected = [74, 116, 101, 115, 116, // "test"
                        40, // Length 40
                        42, // String key(2), varLength
                        95, 48,  // String "_0"
                        36] // Length of UUID
        + Array(id.uuidString.data(using: .utf8)!)
        try compare(value, to: expected)
    }

}

private enum UUIDContainer: Codable, Equatable {
    case test(UUID)
}
