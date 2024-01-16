import Foundation

final class KeyedDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    let content: [DecodingKey: Data]

    init(data: Data, path: [CodingKey], info: UserInfo) throws {
        let decoder = DataDecoder(data: data)
        var content = [DecodingKey: [Data]]()
        while decoder.hasMoreBytes {
            let (key, dataType) = try DecodingKey.decode(from: decoder, path: path)

            do {
                let data = try decoder.getData(for: dataType, path: path)
                guard content[key] != nil else {
                    content[key] = [data]
                    continue
                }
            } catch DecodingError.dataCorrupted(let context) {
                let codingKey = {
                    switch key {
                    case .stringKey(let stringValue):
                        return Key(stringValue: stringValue)
                    case .intKey(let intValue):
                        return Key(intValue: intValue)
                    }
                }()
                var newCodingPath = path
                if let codingKey {
                    newCodingPath += [codingKey]
                }
                let newContext = DecodingError.Context(
                    codingPath: newCodingPath,
                    debugDescription: context.debugDescription,
                    underlyingError: context.underlyingError
                )
                throw DecodingError.dataCorrupted(newContext)
            }

            throw DecodingError.multipleValuesForKey(path, key)
        }
        self.content = content.mapValues { parts in
            guard parts.count > 1 else {
                return parts[0]
            }
            /// We only get here when `forceProtobufCompatibility = true`
            /// So we need to prepend the length of each element
            /// so that `KeyedEncoder` can decode it correctly
            return parts.map {
                $0.count.variableLengthEncoding + $0
            }.joinedData
        }
        super.init(path: path, info: info)
    }

    var allKeys: [Key] {
        content.keys.compactMap { key in
            switch key {
            case .intKey(let value):
                return Key(intValue: value)
            case .stringKey(let value):
                return Key(stringValue: value)
            }
        }
    }

    func contains(_ key: Key) -> Bool {
        content.keys.contains { $0.isEqual(to: key) }
    }

    private func getData(forKey key: CodingKey) throws -> Data {
        guard let data = content.first(where: { $0.key.isEqual(to: key) })?.value else {
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Key not found")
            throw DecodingError.keyNotFound(key, context)
        }
        return data
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        !contains(key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try wrapError(forKey: key) {
            if let optionalType = type as? AnyOptional.Type {
                if let data = try? getData(forKey: key) {
                    let node = DecodingNode(data: data, isOptional: true, path: codingPath, info: userInfo)
                    return try T.init(from: node)
                } else {
                    return optionalType.nilValue as! T
                }
            } else if let Primitive = type as? DecodablePrimitive.Type {
                let data = try getData(forKey: key)
                return try Primitive.init(decodeFrom: data, path: codingPath + [key]) as! T
            } else {
                let data = try getData(forKey: key)
                let node = DecodingNode(data: data, path: codingPath, info: userInfo)
                return try T.init(from: node)
            }
        }
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        try wrapError(forKey: key) {
            let data = try getData(forKey: key)
            let container = try KeyedDecoder<NestedKey>(data: data, path: codingPath, info: userInfo)
            return KeyedDecodingContainer(container)
        }
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        try wrapError(forKey: key) {
            let data = try getData(forKey: key)
            return try UnkeyedDecoder(data: data, path: codingPath, info: userInfo)
        }
    }

    func superDecoder() throws -> Decoder {
        let data = try getData(forKey: SuperEncoderKey())
        return DecodingNode(data: data, path: codingPath, info: userInfo)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        let data = try getData(forKey: key)
        return DecodingNode(data: data, path: codingPath, info: userInfo)
    }

    private func wrapError<T>(forKey key: Key, _ block: () throws -> T) throws -> T {
        do {
            return try block()
        } catch DecodingError.dataCorrupted(let context) {
            let newContext = DecodingError.Context(
                codingPath: codingPath + [key] + context.codingPath,
                debugDescription: context.debugDescription,
                underlyingError: context.underlyingError
            )
            throw DecodingError.dataCorrupted(newContext)
        }
    }
}
