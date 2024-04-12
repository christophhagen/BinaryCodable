import Foundation

struct PrimitiveEncodingContainer: EncodableContainer {

    let needsLengthData: Bool

    let wrapped: EncodablePrimitive

    let needsNilIndicator = false

    let isNil = false

    init(wrapped: EncodablePrimitive, needsLengthData: Bool) {
        self.needsLengthData = needsLengthData
        self.wrapped = wrapped
    }

    func containedData() -> Data {
        wrapped.encodedData
    }
}
