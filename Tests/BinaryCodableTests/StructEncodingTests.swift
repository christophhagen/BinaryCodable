import XCTest
@testable import BinaryCodable

final class StructEncodingTests: XCTestCase {

    func testStructWithArray() throws {
        struct Test: Codable {
            let val: [Bool]
        }
        let expected: [UInt8] = [0b00110111, 118, 97, 108,
                                 4, 0, 1, 0, 1]
        try compare(Test(val: [true, false, true]), to: expected)
    }
}
