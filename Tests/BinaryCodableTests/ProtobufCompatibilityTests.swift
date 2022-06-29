import XCTest
import BinaryCodable
import SwiftProtobuf

final class ProtobufCompatibilityTests: XCTestCase {

    func testProtoToCodable<T>(_ value: SwiftProtobuf.Message, expected: T) throws where T: Decodable, T: Equatable {
        let data = try value.serializedData()

        let decoder = BinaryDecoder()
        decoder.forceProtobufCompatibility = true
        let decoded = try decoder.decode(T.self, from: data)
        XCTAssertEqual(decoded, expected)
    }

    func testCodableToProto<T, P>(_ value: T, expected: P) throws where T: Encodable, P: SwiftProtobuf.Message, P: Equatable {
        let encoder = BinaryEncoder()
        encoder.forceProtobufCompatibility = true

        let data = try encoder.encode(value)

        let decoded = try P.init(serializedData: data)
        XCTAssertEqual(decoded, expected)
    }

    func testCompatibilityStruct() throws {
        struct Test: Codable, Equatable {

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
        let integer64: Int64 = 123
        let text = "Some"
        let dataValue = Data(repeating: 42, count: 2)
        let intArray: [UInt32] = [0, .max, 2]

        let codableValue = Test(
            integer64: integer64,
            text: text,
            data: dataValue,
            intArray: intArray)

        let protoValue = SimpleStruct.with {
            $0.integer64 = integer64
            $0.text = text
            $0.data = dataValue
            $0.intArray = intArray
        }

        try testProtoToCodable(protoValue, expected: codableValue)
        try testCodableToProto(codableValue, expected: protoValue)
    }

    func testCompatibilityWrappers() throws {
        struct Test: Codable, Equatable {

            @FixedSize
            var fixed32: Int32

            @FixedSize
            var fixedU32: UInt32

            @FixedSize
            var fixed64: Int64

            @FixedSize
            var fixedU64: UInt64

            @PositiveInteger
            var signed32: Int32

            @PositiveInteger
            var signed64: Int64

            enum CodingKeys: Int, CodingKey {
                case fixed32 = 1
                case fixedU32 = 2
                case fixed64 = 3
                case fixedU64 = 4
                case signed32 = 5
                case signed64 = 6
            }
        }
        let fixed32: Int32 = -123
        let fixedU32: UInt32 = 123
        let fixed64: Int64 = -123456789012
        let fixedU64: UInt64 = 123456789012
        let signed32: Int32 = 1234
        let signed64: Int64 = 123456789

        let codableValue = Test(
            fixed32: fixed32,
            fixedU32: fixedU32,
            fixed64: fixed64,
            fixedU64: fixedU64,
            signed32: signed32,
            signed64: signed64)

        let protoValue = WrappedContainer.with {
            $0.fourByteInt = fixed32
            $0.fourByteUint = fixedU32
            $0.eightByteInt = fixed64
            $0.eightByteUint = fixedU64
            $0.signed32 = signed32
            $0.signed64 = signed64
        }

        try testProtoToCodable(protoValue, expected: codableValue)
        try testCodableToProto(codableValue, expected: protoValue)
    }
}
