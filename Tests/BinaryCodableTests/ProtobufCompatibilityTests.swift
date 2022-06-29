import XCTest
import BinaryCodable

final class ProtobufCompatibilityTests: XCTestCase {

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

        let encoder = BinaryEncoder()
        encoder.forceProtobufCompatibility = true


        let data1 = try encoder.encode(codableValue)
        let data2 = try protoValue.serializedData()

        let _ = try SimpleStruct(serializedData: data2)
        let decoded1 = try SimpleStruct(serializedData: data1)
        XCTAssertEqual(decoded1, protoValue)

        let decoder = BinaryDecoder()
        decoder.forceProtobufCompatibility = true
        let decoded2 = try decoder.decode(Test.self, from: data2)
        XCTAssertEqual(decoded2, codableValue)
    }
}
