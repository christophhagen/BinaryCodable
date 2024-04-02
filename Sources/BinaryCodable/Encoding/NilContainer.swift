import Foundation

/**
 A container to signal that `nil` was encoded in a container
 */
struct NilContainer: EncodableContainer {

    let needsLengthData = true

    let needsNilIndicator = true

    let isNil = true

    func containedData() throws -> Data {
        fatalError()
    }
}
