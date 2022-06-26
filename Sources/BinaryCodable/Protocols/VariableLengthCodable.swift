import Foundation

protocol VariableLengthCodable {
    
    var variableLengthEncoding: Data { get }
    
    static func readVariableLengthEncoded(from data: Data) throws -> Self
}
