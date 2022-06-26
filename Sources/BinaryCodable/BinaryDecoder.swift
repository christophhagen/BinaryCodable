import Foundation

/**
 An encoder to convert binary data back to `Codable` objects.
 */
public final class BinaryDecoder {

    /**
     Create a new binary encoder.
     */
    public init() {

    }

    public func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        let root = DecodingNode(data: data, codingPath: [], userInfo: [:])
        return try type.init(from: root)
    }
}
