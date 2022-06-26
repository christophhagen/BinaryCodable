import Foundation

public enum BinaryDecodingError: Error {

    case invalidDataSize

    case invalidData

    case notImplemented

    case missingDataForKey(CodingKey)

    case unknownDataType(Int)

    case prematureEndOfData

    case integerOutOfRange

    case invalidString
}
