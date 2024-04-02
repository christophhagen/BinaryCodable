import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    private let data: Data?

    init(data: Data?, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
        self.data = data
        super.init(parentDecodedNil: false, codingPath: codingPath, userInfo: userInfo)
    }

    func decodeNil() -> Bool {
        data == nil
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try decode(element: data, type: type, codingPath: codingPath)
    }
}
