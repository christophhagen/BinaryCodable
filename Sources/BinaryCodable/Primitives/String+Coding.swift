import Foundation

extension String: EncodablePrimitive {

    var encodedData: Data {
        data(using: .utf8)!
    }
}

extension String: DecodablePrimitive {

    public init(data: Data) throws {
        guard let value = String(data: data, encoding: .utf8) else {
            throw CorruptedDataError(invalidString: data.count)
        }
        self = value
    }
}
