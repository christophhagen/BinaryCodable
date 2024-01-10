import Foundation

final class ValueDecoder: AbstractDecodingNode, SingleValueDecodingContainer {

    private var storage: Storage

    private let isOptional: Bool
    
    private let isInUnkeyedContainer: Bool

    init(storage: Storage, isOptional: Bool, isInUnkeyedContainer: Bool, path: [CodingKey], info: UserInfo) {
        self.storage = storage
        self.isOptional = isOptional
        self.isInUnkeyedContainer = isInUnkeyedContainer
        super.init(path: path, info: info)
    }

    private func asDecoder() -> BinaryStreamProvider {
        let decoder = self.storage.useAsDecoder()
        self.storage = .decoder(decoder)
        return decoder
    }

    func decodeNil() -> Bool {
        do {
            let byte = try asDecoder().getByte(path: codingPath)
            return byte == 0
        } catch {
            return false
        }
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        if type is AnyOptional.Type {
            let node = DecodingNode(storage: storage, isOptional: true, path: codingPath, info: userInfo)
            return try T.init(from: node)
        } else if let Primitive = type as? DecodablePrimitive.Type {
            let data: Data
            if !isInUnkeyedContainer, Primitive.dataType == .variableLength, !isOptional {
                switch storage {
                case .data(let d):
                    data = d
                case .decoder(let decoder):
                    if let d = decoder as? DataDecoder {
                        data = d.getAllData()
                    } else {
                        data = try decoder.getData(for: Primitive.dataType, path: codingPath)
                    }
                }
            } else {
                let decoder = asDecoder()
                data = try decoder.getData(for: Primitive.dataType, path: codingPath)
            }
            return try Primitive.init(decodeFrom: data, path: codingPath) as! T
        } else {
            let node = DecodingNode(storage: storage, path: codingPath, info: userInfo)
            return try T.init(from: node)
        }
    }
}
