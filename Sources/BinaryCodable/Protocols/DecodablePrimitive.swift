import Foundation

/**
 A protocol adopted by primitive types for decoding.
 */
protocol DecodablePrimitive {

    /**
     Decode a value from the data.
     - Note: All provided data can be used
     - Throws: Errors of type ``CorruptDataError``
     */
    init(data: Data) throws
}
