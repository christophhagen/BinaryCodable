import XCTest
@testable import BinaryCodable

final class ProtobufDescriptionTests: XCTestCase {

    private func failingProtobufDefinition<T>(_ value: T) where T: Encodable {
        do {
            let definition = try ProtobufEncoder().getProtobufDefinition(value)
            XCTFail("Created invalid definition for \(type(of: value)): \(definition)")
        } catch BinaryEncodingError.notProtobufCompatible {

        } catch {
            XCTFail("Failed protobuf definition for \(type(of: value)) with error: \(error)")
        }
    }

    func testFailPrimitiveTypes() throws {
        failingProtobufDefinition(123)
        failingProtobufDefinition(Int32(123))
    }

    func testStructDefinition() throws {
        struct Test: Codable {

            var integer64: Int64

            var text: String

            var data: Data

            var intArray: [UInt32]

            enum CodingKeys: Int, CodingKey {
                case integer64 = 1
                case text = 2
                case data = 3
                case intArray = 4
            }
        }
        let value = Test(
            integer64: 123,
            text: "",
            data: Data([1]),
            intArray: [1, 2])
        let definition = try ProtobufEncoder().getProtobufDefinition(value)
        let expected =
            """
            syntax = "proto3";

            message Test {

              sint64 integer64 = 1;

              string text = 2;

              bytes data = 3;

              repeated uint32 intArray = 4;
            }
            """
        XCTAssertEqual(definition, expected)
    }
}
