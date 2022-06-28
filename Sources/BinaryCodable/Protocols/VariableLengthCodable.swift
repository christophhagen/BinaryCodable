import Foundation

protocol VariableLengthCodable {
    
    var variableLengthEncoding: Data { get }
    
    init(fromVarint data: Data) throws
}
