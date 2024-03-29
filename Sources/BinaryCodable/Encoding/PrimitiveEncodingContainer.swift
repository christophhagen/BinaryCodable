import Foundation

struct PrimitiveEncodingContainer: EncodableContainer {

    let needsLengthData: Bool

    let wrapped: EncodablePrimitive

    var needsNilIndicator: Bool { false }

    var isNil: Bool { false }

    init(wrapped: EncodablePrimitive, needsLengthData: Bool) {
        self.needsLengthData = needsLengthData
        self.wrapped = wrapped
    }

    func containedData() throws -> Data {
        wrapped.encodedData
    }
}
