import Foundation

protocol DecodablePrimitive {

    init(decodeFrom data: Data) throws
}
