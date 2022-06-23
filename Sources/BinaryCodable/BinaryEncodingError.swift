import Foundation

public enum BinaryEncodingError: Error {
    
    case prematureEndOfData
    
    case variableLengthEncodedIntegerOutOfRange
}
