import XCTest
@testable import BinaryCodable

private struct CodablePrimitiveContainer: Codable, Equatable {

    var doubleValue: Double = .zero
    var floatValue: Float = .zero
    var intValue32: Int32 = .zero
    var intValue64: Int64 = .zero
    var uIntValue32: UInt32 = .zero
    var uIntValue64: UInt64 = .zero
    @SignedValue var sIntValue32: Int32 = .zero
    @SignedValue var sIntValue64: Int64 = .zero
    @FixedSize var fIntValue32: UInt32 = .zero
    @FixedSize var fIntValue64: UInt64 = .zero
    @FixedSize var sfIntValue32: Int32 = .zero
    @FixedSize var sfIntValue64: Int64 = .zero
    var boolValue: Bool = .zero
    var stringValue: String = .zero
    var dataValue: Data = .zero

    enum CodingKeys: Int, CodingKey {
        case doubleValue = 1
        case floatValue = 2
        case intValue32 = 3
        case intValue64 = 4
        case uIntValue32 = 5
        case uIntValue64 = 6
        case sIntValue32 = 7
        case sIntValue64 = 8
        case fIntValue32 = 9
        case fIntValue64 = 10
        case sfIntValue32 = 11
        case sfIntValue64 = 12
        case boolValue = 13
        case stringValue = 14
        case dataValue = 15
    }

    var proto: PrimitiveTypesContainer {
        .with {
            $0.doubleValue = doubleValue
            $0.floatValue = floatValue
            $0.intValue32 = intValue32
            $0.intValue64 = intValue64
            $0.uIntValue32 = uIntValue32
            $0.uIntValue64 = uIntValue64
            $0.sIntValue32 = sIntValue32
            $0.sIntValue64 = sIntValue64
            $0.fIntValue32 = fIntValue32
            $0.fIntValue64 = fIntValue64
            $0.sfIntValue32 = sfIntValue32
            $0.sfIntValue64 = sfIntValue64
            $0.boolValue = boolValue
            $0.stringValue = stringValue
            $0.dataValue = dataValue
        }
    }
}

final class ProtobufPrimitiveTests: XCTestCase {

    private func compare(_ value: CodablePrimitiveContainer, to expected: [UInt8]) throws {
        let protoData = try value.proto.serializedData()
        XCTAssertEqual(Array(protoData), expected)
        let encoder = ProtobufEncoder()
        let codableData = try encoder.encode(value)
        XCTAssertEqual(Array(codableData), expected)

        let decoder = ProtobufDecoder()
        let decoded = try decoder.decode(CodablePrimitiveContainer.self, from: codableData)
        XCTAssertEqual(value, decoded)
    }

    func testDoubleValue() throws {
        let value = CodablePrimitiveContainer(doubleValue: 123)
        let expected: [UInt8] = [ 1 << 3 | 1, 0, 0, 0, 0, 0, 192, 94, 64]
        try compare(value, to: expected)
    }

    func testFloatValue() throws {
        let value = CodablePrimitiveContainer(floatValue: 123)
        let expected: [UInt8] = [ 2 << 3 | 5, 0, 0, 246, 66]
        try compare(value, to: expected)
    }

    func testInt32Value() throws {
        let value = CodablePrimitiveContainer(intValue32: 123)
        let expected: [UInt8] = [ 3 << 3 | 0, 123]
        try compare(value, to: expected)
    }

    func testInt64Value() throws {
        let value = CodablePrimitiveContainer(intValue64: 123)
        let expected: [UInt8] = [ 4 << 3 | 0, 123]
        try compare(value, to: expected)
    }

    func testUInt32Value() throws {
        let value = CodablePrimitiveContainer(uIntValue32: 123)
        let expected: [UInt8] = [ 5 << 3 | 0, 123]
        try compare(value, to: expected)
    }

    func testUInt64Value() throws {
        let value = CodablePrimitiveContainer(uIntValue64: 123)
        let expected: [UInt8] = [ 6 << 3 | 0, 123]
        try compare(value, to: expected)
    }

    func testSInt32Value() throws {
        let value = CodablePrimitiveContainer(sIntValue32: 123)
        let expected: [UInt8] = [ 7 << 3 | 0, 246, 1]
        try compare(value, to: expected)
    }

    func testSInt64Value() throws {
        let value = CodablePrimitiveContainer(sIntValue64: 123)
        let expected: [UInt8] = [ 8 << 3 | 0, 246, 1]
        try compare(value, to: expected)
    }

    func testFInt32Value() throws {
        let value = CodablePrimitiveContainer(fIntValue32: 123)
        let expected: [UInt8] = [ 9 << 3 | 5, 123, 0, 0, 0]
        try compare(value, to: expected)
    }

    func testFInt64Value() throws {
        let value = CodablePrimitiveContainer(fIntValue64: 123)
        let expected: [UInt8] = [ 10 << 3 | 1, 123, 0, 0, 0, 0, 0, 0, 0]
        try compare(value, to: expected)
    }

    func testFUInt32Value() throws {
        let value = CodablePrimitiveContainer(sfIntValue32: 123)
        let expected: [UInt8] = [ 11 << 3 | 5, 123, 0, 0, 0]
        try compare(value, to: expected)
    }

    func testFUInt64Value() throws {
        let value = CodablePrimitiveContainer(sfIntValue64: 123)
        let expected: [UInt8] = [ 12 << 3 | 1, 123, 0, 0, 0, 0, 0, 0, 0]
        try compare(value, to: expected)
    }

    func testBoolValue() throws {
        let value = CodablePrimitiveContainer(boolValue: true)
        let expected: [UInt8] = [ 13 << 3 | 0, 1]
        try compare(value, to: expected)
    }

    func testStringValue() throws {
        let value = CodablePrimitiveContainer(stringValue: "abc")
        let expected: [UInt8] = [ 14 << 3 | 2, 3, 97, 98, 99]
        try compare(value, to: expected)
    }

    func testDataValue() throws {
        let value = CodablePrimitiveContainer(dataValue: .init(repeating: 2, count: 3))
        let expected: [UInt8] = [ 15 << 3 | 2, 3, 2, 2, 2]
        try compare(value, to: expected)
    }
}
