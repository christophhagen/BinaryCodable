import Foundation

extension Int {

    /// Encodes the integer as the length of a nil/length indicator
    var lengthData: Data {
        // The first bit (LSB) is the `nil` bit (0)
        // The rest is the length, encoded as a varint
        (UInt64(self) << 1).encodedData
    }
}
