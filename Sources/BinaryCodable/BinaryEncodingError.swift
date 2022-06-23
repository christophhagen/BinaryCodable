import Foundation

public enum BinaryEncodingError: Error {
 
    case multipleAssignmentsToSameKey(CodingKey)
    
    case prematureEndOfData
    
    case variableLengthEncodedIntegerOutOfRange
    
    case stringEncodingFailed(String)
}
