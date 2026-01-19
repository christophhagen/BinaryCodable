import Foundation

/**
 A protocol adopted by primitive types for encoding.
 */
@_spi(Internals) public
protocol EncodableContainer {

    /// Indicate if the container needs to have a length prepended
    var needsLengthData: Bool { get }

    /// Indicate if the container can encode nil
    var needsNilIndicator: Bool { get }

    /// Indicate if the container encodes nil
    /// - Note: This property must not be `true` if `needsNilIndicator` is set to `false`
    var isNil: Bool { get }

    /**
     Provide the data encoded in the container
     - Note: No length information must be included
     - Note: This function is only called if `isNil` is false
     */
    func containedData() throws -> Data
}

extension EncodableContainer {

    /**
     The full data encoded in the container, including nil indicator and length, if needed
     */
    @_spi(Internals) public
    func completeData() throws -> Data {
        guard !isNil else {
            // A nil value always means:
            // - That the length is zero
            // - That a nil indicator is needed
            return Data([0x01])
        }
        let data = try containedData()
        if needsLengthData {
            // It doesn't matter if `needsNilIndicator` is true or false
            // Length always includes it
            return data.count.lengthData + data
        }
        if needsNilIndicator {
            return Data([0x00]) + data
        }
        return data
    }
}
