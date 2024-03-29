import Foundation

/**
 A protocol adopted by primitive types for decoding.
 */
protocol DecodablePrimitive {

    /**
     Decode a value from the data.
     - Note: All provided data can be used
     */
    init(data: Data, codingPath: [CodingKey]) throws
}
