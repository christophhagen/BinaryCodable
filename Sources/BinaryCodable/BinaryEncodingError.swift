import Foundation

public enum BinaryEncodingError: Error {
 
    case multipleAssignmentsToSameKey(CodingKey)
    
    case variableLengthEncodedIntegerOutOfRange
    
    case stringEncodingFailed(String)

    case integerCodingKeyOutOfRange(CodingKey)
}
