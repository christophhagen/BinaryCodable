import Foundation

protocol ZigZagCodable {
    
    var zigZagEncoded: Data { get }
    
    static func readZigZagEncoded(from data: Data) throws -> Self
}
