import Foundation

/**
 A container to signal that `nil` was encoded in a container
 */
struct NilContainer: EncodableContainer {

    var needsLengthData: Bool { false }

    var needsNilIndicator: Bool { true }

    var isNil: Bool { true }

    func containedData() throws -> Data {
        fatalError()
    }
}
