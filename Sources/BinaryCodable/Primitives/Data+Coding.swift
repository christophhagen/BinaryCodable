import Foundation

extension Data: EncodablePrimitive {

    var encodedData: Data {
        self
    }
}

extension Data: DecodablePrimitive {

    init(data: Data, codingPath: [CodingKey]) {
        self = data
    }
}
