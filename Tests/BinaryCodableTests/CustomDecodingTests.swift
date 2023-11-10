import XCTest
import BinaryCodable

private struct Timestamped<Value> {

    let timestamp: Date

    let value: Value

    init(value: Value, timestamp: Date = Date()) {
        self.timestamp = timestamp
        self.value = value
    }

    func mapValue<T>(_ closure: (Value) -> T) -> Timestamped<T> {
        .init(value: closure(value), timestamp: timestamp)
    }
}

extension Timestamped: Encodable where Value: Encodable {

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(timestamp)
        try container.encode(value)
    }
}

extension Timestamped: Decodable where Value: Decodable {

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.timestamp = try container.decode(Date.self)
        self.value = try container.decode(Value.self)
    }
}

extension Timestamped: Equatable where Value: Equatable {
    
}

/// A special semantic version with a fourth number
private struct Version {

    /// The major version of the software
    public let major: Int

    /// The minor version of the software
    public let minor: Int

    /// The patch version of the software
    public let patch: Int

    public let build: Int?

    public init(major: Int, minor: Int, patch: Int, build: Int? = nil) {
        self.major = major
        self.minor = minor
        self.patch = patch
        self.build = build
    }
}

extension Version: RawRepresentable {

    var rawValue: String {
        guard let build else {
            return "\(major).\(minor).\(patch)"
        }
        return "\(major).\(minor).\(patch).\(build)"
    }

    init?(rawValue: String) {
        let parts = rawValue
            .trimmingCharacters(in: .whitespaces)
            .components(separatedBy: ".")
        guard parts.count == 3 || parts.count == 4 else {
            return nil
        }
        guard let major = Int(parts[0]),
              let minor = Int(parts[1]),
              let patch = Int(parts[2]) else {
            return nil
        }
        self.major = major
        self.minor = minor
        self.patch = patch

        guard parts.count == 4 else {
            self.build = nil
            return
        }
        guard let build = Int(parts[3]) else {
            return nil
        }
        self.build = build
    }
}

extension Version: Decodable { }
extension Version: Encodable { }
extension Version: Equatable { }



final class CustomDecodingTests: XCTestCase {

    func testCustomDecoding() throws {
        let value = Timestamped(value: "Some")
        let encoded = try BinaryEncoder().encode(value)
        let decoded = try BinaryDecoder().decode(Timestamped<String>.self, from: encoded)
        XCTAssertEqual(value, decoded)
    }
    
    func testCustomVersionDecoding() throws {
        let version = Version(major: 1, minor: 2, patch: 3)
        let value = Timestamped(value: version)
        let encoded = try BinaryEncoder().encode(value)
        let decoded = try BinaryDecoder().decode(Timestamped<Version>.self, from: encoded)
        XCTAssertEqual(version, decoded.value)
    }
    
    func testDecodingAsDifferentType() throws {
        let version = Version(major: 1, minor: 2, patch: 3)
        let encoded = try BinaryEncoder().encode(version)
        let decoded = try BinaryDecoder().decode(String.self, from: encoded)
        let encoded2 = try BinaryEncoder().encode("1.2.3")
        print(Array(encoded2))
        let decoded2 = try BinaryDecoder().decode(Version.self, from: encoded2)
        XCTAssertEqual(version.rawValue, decoded)
        XCTAssertEqual(version, decoded2)
    }
    
    func testEncodingAsDifferentType() throws {
        let version = Version(major: 1, minor: 2, patch: 3)
        let time = Date.now
        let sValue = Timestamped(value: version.rawValue, timestamp: time)
        let vValue = Timestamped(value: version, timestamp: time)
        let encoder = BinaryEncoder()
        let sEncoded = try encoder.encode(sValue)
        let vEncoded = try encoder.encode(vValue)
        XCTAssertEqual(Array(sEncoded), Array(vEncoded))
    }
}
