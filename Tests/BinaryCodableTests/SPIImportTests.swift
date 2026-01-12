import XCTest
import Foundation
@_spi(Internals) import BinaryCodable

final class SPIImportTests: XCTestCase {

    // MARK: - EncodingNode Tests

    func testEncodingNodeImport() {
        // Test will fail to compile if EncodingNode is not accessible via SPI
        let _ = EncodingNode(needsLengthData: false, codingPath: [], userInfo: [:])
    }

    func testEncodingNodeProperties() {
        let encoder = EncodingNode(needsLengthData: true, codingPath: [], userInfo: [:])
        let _ = encoder.needsLengthData
        let _ = encoder.codingPath
        let _ = encoder.userInfo
    }

    func testEncodingNodeContainerMethods() {
        struct TestKey: CodingKey {
            var stringValue: String
            var intValue: Int?
            init(stringValue: String) { self.stringValue = stringValue }
            init(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
        }
        
        // Each container method must be called on a separate encoder instance
        let encoder1 = EncodingNode(needsLengthData: false, codingPath: [], userInfo: [:])
        let _ = encoder1.container(keyedBy: TestKey.self)
        
        let encoder2 = EncodingNode(needsLengthData: false, codingPath: [], userInfo: [:])
        let _ = encoder2.unkeyedContainer()
        
        let encoder3 = EncodingNode(needsLengthData: false, codingPath: [], userInfo: [:])
        let _ = encoder3.singleValueContainer()
    }

    func testEncodingNodeEncodableContainerProperties() {
        let encoder = EncodingNode(needsLengthData: false, codingPath: [], userInfo: [:])
        let _ = encoder.needsNilIndicator
        let _ = encoder.isNil
    }

    // MARK: - DecodingNode Tests

    func testDecodingNodeImport() throws {
        // Test will fail to compile if DecodingNode is not accessible via SPI
        let _ = try DecodingNode(data: Data([1, 2, 3]), parentDecodedNil: false, codingPath: [], userInfo: [:])
    }

    func testDecodingNodeProperties() throws {
        struct TestKey: CodingKey {
            var stringValue: String
            var intValue: Int?
            init(stringValue: String) { self.stringValue = stringValue }
            init(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
        }
        
        let decoder = try DecodingNode(data: Data([1, 2, 3]), parentDecodedNil: false, codingPath: [TestKey(stringValue: "test")], userInfo: [:])
        let _ = decoder.codingPath
        let _ = decoder.userInfo
    }
    // MARK: - AbstractNode Tests

    func testAbstractNodeProperties() {
        struct TestKey: CodingKey {
            var stringValue: String
            var intValue: Int?
            init(stringValue: String) { self.stringValue = stringValue }
            init(intValue: Int) { self.stringValue = "\(intValue)"; self.intValue = intValue }
        }
        
        let encoder = EncodingNode(needsLengthData: false, codingPath: [TestKey(stringValue: "test")], userInfo: [:])
        let _ = encoder.codingPath
        let _ = encoder.userInfo
    }

    // MARK: - AbstractEncodingNode Tests

    func testAbstractEncodingNodeProperties() {
        let encoder = EncodingNode(needsLengthData: true, codingPath: [], userInfo: [:])
        let _ = encoder.needsLengthData
    }
}
