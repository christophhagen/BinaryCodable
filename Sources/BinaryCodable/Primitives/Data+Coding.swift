import Foundation

extension Data: EncodablePrimitive {

    static var dataType: DataType {
        .variableLength
    }

    func data() -> Data {
        self
    }
}

extension Data: DecodablePrimitive {

    init(decodeFrom data: Data) {
        self = Data(data)
    }
}

