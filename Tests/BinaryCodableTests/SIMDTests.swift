import Foundation
import XCTest
@testable import BinaryCodable
#if canImport(simd)
import simd


final class SIMDTests: XCTestCase {

    func testSIMDDouble() throws {
        let double = 3.14
        let value = SIMD2(x: double, y: double)
        // Double has length 8, so prepend 16
        let doubleData = [16] + Array(double.encodedData)
        try compare(value, to: doubleData + doubleData)
    }
}
#endif
