import XCTest
@testable import BinaryCodable

/**
 A variety of tests to ensure that errors are handled correctly
 */
final class DecodingErrorTests: XCTestCase {

    func testInt32OutOfRange() throws {
        // Encode a value that is out of range
        let value = Int64(Int32.max) + 1
        let encoded = try BinaryEncoder.encode(value)
        
        do {
            _ = try BinaryDecoder.decode(Int32.self, from: encoded)
            XCTFail("Should fail to decode Int32")
        } catch let DecodingError.dataCorrupted(context) {
            XCTAssertEqual(context.codingPath, [])
        }
        
        do {
            _ = try Int32(fromZigZag: encoded)
            XCTFail("Should fail to decode Int32")
        } catch is CorruptedDataError {
            
        }
        
        // Encode a value that is out of range
        let value2 = Int64(Int32.min) - 1
        let encoded2 = try BinaryEncoder.encode(value2)
        
        do {
            _ = try BinaryDecoder.decode(Int32.self, from: encoded2)
            XCTFail("Should fail to decode Int32")
        } catch let DecodingError.dataCorrupted(context) {
            XCTAssertEqual(context.codingPath, [])
        }
        
        do {
            _ = try Int32(fromZigZag: encoded2)
            XCTFail("Should fail to decode Int32")
        } catch is CorruptedDataError {
            
        }
    }
    
    func testUInt32OutOfRange() throws {
        // Encode a value that is out of range
        let value = UInt64(UInt32.max) + 1
        let encoded = try BinaryEncoder.encode(value)
        
        do {
            _ = try BinaryDecoder.decode(UInt32.self, from: encoded)
            XCTFail("Should fail to decode UInt32")
        } catch let DecodingError.dataCorrupted(context) {
            XCTAssertEqual(context.codingPath, [])
        }
        
        do {
            _ = try UInt32(fromVarint: encoded)
            XCTFail("Should fail to decode UInt32")
        } catch is CorruptedDataError {
            
        }
    }

}
