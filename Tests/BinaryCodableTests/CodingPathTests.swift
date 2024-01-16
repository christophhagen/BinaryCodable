import XCTest
import BinaryCodable

final class CodingPathTests: XCTestCase {

    struct KeyedBox<T: Codable>: Codable {
        enum CodingKeys: String, CodingKey {
            case val
        }

        let val: T

        init(_ val: T) {
            self.val = val
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.val = try container.decode(T.self, forKey: .val)
        }
    }

    struct CorruptBool: Codable, Equatable, ExpressibleByBooleanLiteral {
        let val: Bool

        init(booleanLiteral value: BooleanLiteralType) {
            self.val = value
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            self.val = try container.decode(Bool.self)
            if val == false {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Found false!")
            }
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encode(val)
        }
    }

    func testStructWithCorruptArrayElement() throws {
        struct Test: Codable, Equatable {
            let arr: [CorruptBool]
        }
        
        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            8, // Length of val
            0b00111010, 97, 114, 114, // String key 'arr', varint
            3, // 3 elements
            1, 1, 0 // True, true, corrupt!
        ]

        let data = try BinaryEncoder().encode(KeyedBox(Test(arr: [true, true, false])))
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<Test>.self, from: data)
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val", "arr", "2"])
        }
    }

    func testStructWithArrayMissingLastElement() throws {
        struct Test: Codable, Equatable {
            let arr: [Bool]
        }

        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            8, // Length of val
            0b00111010, 97, 114, 114, // String key 'arr', varint
            3, // 3 elements
            1, 1 // Only two elements provided!
        ]

        var data = try BinaryEncoder().encode(KeyedBox(Test(arr: [true, true, false])))
        data.removeLast()
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<Test>.self, from: Data(corruptedBytes))
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val"])
        }
    }

    func testStructWithArrayMissingLastElementButCorrectLength() throws {
        struct Test: Codable, Equatable {
            let arr: [Bool]
        }

        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            7, // Length of val
            0b00111010, 97, 114, 114, // String key 'arr', varint
            3, // 3 elements
            1, 1 // Only two elements provided!
        ]

        var data = try BinaryEncoder().encode(KeyedBox(Test(arr: [true, true, false])))
        data[4] -= 1
        data.removeLast()
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<Test>.self, from: Data(corruptedBytes))
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val", "arr"])
        }
    }

    func testStructWithCorruptDataOnKeyedNestedContainer() throws {
        struct Test: Codable, Equatable {
            enum CodingKeys: String, CodingKey {
                case nested
            }

            enum NestedCodingKeys: String, CodingKey {
                case bool
            }

            let bool: CorruptBool

            init(bool: CorruptBool) {
                self.bool = bool
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let nestedContainer = try container.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .nested)
                self.bool = try nestedContainer.decode(CorruptBool.self, forKey: .bool)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                var nestedContainer = container.nestedContainer(keyedBy: NestedCodingKeys.self, forKey: .nested)
                try nestedContainer.encode(bool, forKey: .bool)
            }
        }
        
        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            14, // Byte length of val value
            0b01101010, 110, 101, 115, 116, 101, 100, // String key 'nested', varint
            6, // Byte length of nested value
            0b01001000, 98, 111, 111, 108, // String key 'bool', varint
            0, // Corrupt!
        ]

        let data = try BinaryEncoder().encode(KeyedBox(Test(bool: false)))
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<Test>.self, from: data)
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val", "bool"])
        }
    }

    func testStructWithCorruptDataOnUnkeyedNestedContainer() throws {
        struct TestWrapper: Codable, Equatable {
            enum CodingKeys: String, CodingKey {
                case nested
            }

            enum NestedCodingKeys: String, CodingKey {
                case bool
            }

            let val: Test

            init(val: Test) {
                self.val = val
            }

            init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                var nestedContainer = try container.nestedUnkeyedContainer(forKey: .nested)
                self.val = try nestedContainer.decode(Test.self)
            }

            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                var nestedContainer = container.nestedUnkeyedContainer(forKey: .nested)
                try nestedContainer.encode(val)
            }
        }
        struct Test: Codable, Equatable {
            let bool: CorruptBool
        }

        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            15, // Byte length of val value
            0b01101010, 110, 101, 115, 116, 101, 100, // String key 'nested', varint
            7, // Byte length of nested value
            6, // Byte length of unkeyed container
            0b01001000, 98, 111, 111, 108, // String key 'bool', varint
            0 // Corrupt!
        ]

        let data = try BinaryEncoder().encode(KeyedBox(TestWrapper(val: Test(bool: false))))
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<TestWrapper>.self, from: data)
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val", "0", "bool"])
        }
    }

    func testOptionalStructWithMissingValueAndWrongLengths() throws {
        struct Test: Codable, Equatable {
            let bool: Bool
        }
        
        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            8, // Supposed byte length of optional val
            1, // 1 optional,
            6, // Supposed byte length of wrapped val
            0b01001000, 98, 111, 111, 108, // String key 'bool', varint
            // No value!
        ]

        let box: KeyedBox<Test?> = KeyedBox(Test(bool: true))

        var data = try BinaryEncoder().encode(box)
        data.removeLast()
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<Test?>.self, from: data)
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val"])
        }
    }

    func testOptionalStructWithMissingValueAndWrongNestedLength() throws {
        struct Test: Codable, Equatable {
            let bool: Bool
        }
        
        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            7, // Byte length of optional val (modified!)
            1, // 1 as in the optional is present,
            6, // Supposed byte length of wrapped val
            0b01001000, 98, 111, 111, 108, // String key 'bool', varint
            // No value!
        ]

        let box: KeyedBox<Test?> = KeyedBox(Test(bool: true))

        var data = try BinaryEncoder().encode(box)
        data[4] -= 1
        data.removeLast()
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<Test?>.self, from: data)
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val"])
        }
    }

    func testOptionalStructWithMissingValueButCorrectByteLengths() throws {
        struct Test: Codable, Equatable {
            let bool: Bool
        }

        let corruptedBytes: [UInt8] = [
            0b00111010, 118, 97, 108, // String key 'val', varint
            7, // Byte length of optional val (modified!)
            1, // 1 as in the optional is present,
            5, // Byte length of wrapped val (modified!)
            0b01001000, 98, 111, 111, 108, // String key 'bool', varint
            // No value!
        ]

        let box: KeyedBox<Test?> = KeyedBox(Test(bool: true))

        var data = try BinaryEncoder().encode(box)
        data[4] -= 1
        data[6] -= 1
        data.removeLast()
        XCTAssertEqual(Array(data), corruptedBytes)

        do {
            let _ = try BinaryDecoder().decode(KeyedBox<Test?>.self, from: data)
            XCTFail("Unexpected succeded!")
        } catch let error as DecodingError {
            guard case .dataCorrupted(let context) = error else {
                XCTFail("Unexpected error!")
                return
            }
            XCTAssertEqual(context.codingPath.map { $0.stringValue }, ["val", "bool"])
        }
    }
}
