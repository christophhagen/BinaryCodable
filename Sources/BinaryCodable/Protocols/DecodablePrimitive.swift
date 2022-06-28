import Foundation

protocol DecodablePrimitive: DataTypeProvider {

    init(decodeFrom data: Data) throws
}
