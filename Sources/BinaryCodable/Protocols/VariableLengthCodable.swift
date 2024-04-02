import Foundation

typealias VariableLengthCodable = VariableLengthEncodable & VariableLengthDecodable

protocol VariableLengthEncodable: FixedWidthInteger {

    var variableLengthEncoding: Data { get }
}

protocol VariableLengthDecodable: FixedWidthInteger {

    init(fromVarint data: Data, codingPath: [CodingKey]) throws
}
