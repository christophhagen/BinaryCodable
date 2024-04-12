import Foundation

extension Data: EncodablePrimitive {

    var encodedData: Data {
        self
    }
}

extension Data: DecodablePrimitive {

    public init(data: Data) {
        self = data
    }
}
