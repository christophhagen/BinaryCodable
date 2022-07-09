import Foundation

/**
 An error produced while decoding binary data.
 */
public enum BinaryDecodingError: Error {

    /**
     The data for a primitive type did not have the right size.
     - Note: This error is internal and should not occur in practice.
     */
    case invalidDataSize

    /**
     The binary data is missing for a key.

     The associated value is the `CodingKey` not found in the data.
     */
    case missingDataForKey(CodingKey)

    /**
     The binary data contained an unknown data type.

     The associated value is the unknown raw value of the data type.
     */
    case unknownDataType(Int)

    /**
     The binary data ended before all values were decoded.
     */
    case prematureEndOfData

    /**
     A `String` contained in the data could not be decoded.

     The failing string can be either a value, or a string key (e.g. a property name or enum case).
     */
    case invalidString

    /**
     An integer encoded in the binary data as a varint does not fit into the specified integer type, producing an overflow.
     */
    case variableLengthEncodedIntegerOutOfRange

    /**
     The binary data contains multiple values for a key.
     */
    case multipleValuesForKey
}
