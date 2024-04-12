import Foundation

/**
 A protocol for types which can be decoded from a continous stream of data
 */
protocol PackedDecodable {

    /**
     Decode a value from a data stream at a given index.

     This function is expected to advance the buffer index appropriately.
     */
    init(data: Data, index: inout Int) throws

}

