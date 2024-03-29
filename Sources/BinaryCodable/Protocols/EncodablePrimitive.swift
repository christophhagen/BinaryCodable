import Foundation

/**
 A protocol adopted by all base types (Int, Data, String, ...) to provide the encoded data.
 */
protocol EncodablePrimitive {

    /**
     The raw data of the encoded base type value.
     - Note: No length information must be included
     */
    var encodedData: Data { get }
}
