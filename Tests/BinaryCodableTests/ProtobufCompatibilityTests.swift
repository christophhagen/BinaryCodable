import XCTest
import BinaryCodable
import SwiftProtobuf

private struct Simple: Codable, Equatable {

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

extension Simple {

    var proto: SimpleStruct {
        .with {
            $0.integer64 = integer64
            $0.text = text
            $0.data = data
            $0.intArray = intArray
        }
    }
}

private struct MapTest: Codable, Equatable {
    let x: [String: Data]
    let y: [UInt32: String]

    enum CodingKeys: Int, CodingKey {
        case x = 1
        case y = 2
    }
}

final class ProtobufCompatibilityTests: XCTestCase {

    func testProtoToCodable<T>(_ value: SwiftProtobuf.Message, expected: T) throws where T: Decodable, T: Equatable {
        let data = try value.serializedData()

        let decoder = ProtobufDecoder()
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            XCTAssertEqual(decoded, expected)
        } catch {
            print(Array(data))
            throw error
        }
    }

    func testCodableToProto<T, P>(_ value: T, expected: P) throws where T: Encodable, P: SwiftProtobuf.Message, P: Equatable {
        let encoder = ProtobufEncoder()

        let data = try encoder.encode(value)

        do {
            let decoded = try P.init(serializedData: data)
            XCTAssertEqual(decoded, expected)
        } catch {
            print(Array(data))
            throw error
        }
    }

    private let simple = Simple(
        integer64: 123,
        text: "Some",
        data: Data(repeating: 42, count: 2),
        intArray: [0, .max, 2])

    func testCompatibilityStruct() throws {

        try testProtoToCodable(simple.proto, expected: simple)
        try testCodableToProto(simple, expected: simple.proto)
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

            @SignedValue
            var signed32: Int32

            @SignedValue
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

        let emptyCodable = Test(
            fixed32: 0,
            fixedU32: 0,
            fixed64: 0,
            fixedU64: 0,
            signed32: 0,
            signed64: 0)

        let emptyProto = WrappedContainer()

        XCTAssertEqual(try emptyProto.serializedData(), Data())
        XCTAssertEqual(try ProtobufEncoder().encode(emptyCodable), Data())

        try testProtoToCodable(protoValue, expected: codableValue)
        try testCodableToProto(codableValue, expected: protoValue)

    }

    func testNormalIntegerEncoding() throws {
        struct Test: Codable, Equatable {

            var integer: Int32

            enum CodingKeys: Int, CodingKey {
                case integer = 1
            }
        }

        let codable = Test(integer: 123)
        let data = try ProtobufEncoder().encode(codable)
        XCTAssertEqual(Array(data), [8, 123])
    }

    func testNestedStructs() throws {
        struct Wrapped: Codable, Equatable {

            let inner: Simple

            let more: Simple

            enum CodingKeys: Int, CodingKey {
                case inner = 1
                case more = 2
            }
        }

        let more = Simple(
            integer64: 123,
            text: "More",
            data: .init(repeating: 56, count: 5),
            intArray: [0, 255, .max])

        let value = Wrapped(
            inner: simple,
            more: more)

        let proto = Outer.with {
            $0.inner = simple.proto
            $0.more = more.proto
        }

        try testProtoToCodable(proto, expected: value)
        try testCodableToProto(value, expected: proto)
    }

    func testStructArrays() throws {
        struct Wrapped: Codable, Equatable {

            let values: [Simple]

            enum CodingKeys: Int, CodingKey {
                case values = 1
            }
        }

        let more = Simple(integer64: 123, text: "More", data: .init(repeating: 56, count: 5), intArray: [0, 255, .max])

        let value = Wrapped(values: [simple, more])

        let proto = Outer2.with {
            $0.values = [simple.proto, more.proto]
        }

        try testCodableToProto(value, expected: proto)
        try testProtoToCodable(proto, expected: value)
    }

    func testProtoMaps() throws {
        let x: [String: Data] = ["a" : .init(repeating: 2, count: 2), "b": .init(repeating: 1, count: 1)]
        let y: [UInt32: String] = [123: "a", 234: "b"]

        let proto = MapContainer.with {
            $0.x = x
            $0.y = y
        }
        let codable = MapTest(x: x, y: y)
        
        try testCodableToProto(codable, expected: proto)
        try testProtoToCodable(proto, expected: codable)
    }

    func testProtoMapsWithDefaultValues() throws {
        let x: [String: Data] = ["" : .init(repeating: 2, count: 2), "b": Data()]
        let y: [UInt32: String] = [0: "a", 234: ""]

        let proto = MapContainer.with {
            $0.x = x
            $0.y = y
        }
        let codable = MapTest(x: x, y: y)

        try testCodableToProto(codable, expected: proto)
        try testProtoToCodable(proto, expected: codable)
    }

    func testDefaultValues() throws {
        let codable = Simple(
            integer64: 0,
            text: "",
            data: Data(),
            intArray: [])

        let proto = codable.proto

        try testCodableToProto(codable, expected: proto)
        try testProtoToCodable(proto, expected: codable)
    }

    func testFieldNumberBounds() throws {
        struct FieldBounds: Codable, Equatable {
            let low: Bool
            let high: Bool

            enum CodingKeys: Int, CodingKey {
                case low = 1
                case high = 536870911
            }
        }

        let codable = FieldBounds(low: true, high: true)
        let proto = FieldNumberTest.with {
            $0.low = true
            $0.high = true
        }
        try testCodableToProto(codable, expected: proto)
        try testProtoToCodable(proto, expected: codable)

        struct FieldOutOfLowBounds: Codable, Equatable {
            let low: Bool
            let high: Bool

            enum CodingKeys: Int, CodingKey {
                case low = 0
                case high = 536870911
            }
        }
        let codable2 = FieldOutOfLowBounds(low: true, high: true)
        do {
            let encoder = ProtobufEncoder()
            _ = try encoder.encode(codable2)
        } catch BinaryCodable.BinaryEncodingError.notProtobufCompatible {

        }

        struct FieldOutOfHighBounds: Codable, Equatable {
            let low: Bool
            let high: Bool

            enum CodingKeys: Int, CodingKey {
                case low = 1
                case high = 536870912
            }
        }
        let codable3 = FieldOutOfHighBounds(low: true, high: true)
        do {
            let encoder = ProtobufEncoder()
            _ = try encoder.encode(codable3)
        } catch BinaryCodable.BinaryEncodingError.notProtobufCompatible {

        }
    }
}
