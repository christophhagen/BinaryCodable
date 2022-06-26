import Foundation

protocol DecodablePrimitive {

    init(decodeFrom data: Data) throws

    static var dataType: DataType { get }
}
