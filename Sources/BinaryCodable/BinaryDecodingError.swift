import Foundation

public enum BinaryDecodingError: Error {

    case invalidDataSize


    case missingDataForKey(CodingKey)

    case unknownDataType(Int)

    case prematureEndOfData


    case invalidString
}
