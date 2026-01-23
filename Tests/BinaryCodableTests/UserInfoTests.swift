import XCTest
import BinaryCodable

final class UserInfoTests: XCTestCase {

    func testUserInfoAvailableInEncoderAndDecoder() throws {
        let key = CodingUserInfoKey(rawValue: "SomeKey")!
        let value = true

        struct Unkeyed: SomeCodable {

            static let key = CodingUserInfoKey(rawValue: "SomeKey")!

            static func encode(_ encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()
                if let value = encoder.userInfo[key] as? Bool {
                    XCTAssertTrue(value)
                } else {
                    XCTFail()
                }
                try container.encode(false)
            }

            static func decode(_ decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let value = decoder.userInfo[key] as? Bool {
                    XCTAssertTrue(value)
                } else {
                    XCTFail()
                }
                let decoded = try container.decode(Bool.self)
                XCTAssertEqual(decoded, false)
            }

        }

        var encoder = BinaryEncoder()
        encoder.userInfo[key] = value
        let encoded = try encoder.encode(Unkeyed())
        var decoder = BinaryDecoder()
        decoder.userInfo[key] = value
        _ = try decoder.decode(Unkeyed.self, from: encoded)
    }
}
