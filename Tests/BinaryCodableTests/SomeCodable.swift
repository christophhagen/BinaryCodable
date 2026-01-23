import XCTest
@testable import BinaryCodable

protocol SomeCodable: Codable, Equatable {

    init()

    static func encode(_ encoder: Encoder) throws -> ()

    static func decode(_ decoder: Decoder) throws -> ()
}

extension SomeCodable {

    init(from decoder: any Decoder) throws {
        try Self.decode(decoder)
        self.init()
    }

    func encode(to encoder: any Encoder) throws {
        try Self.encode(encoder)
    }
}
