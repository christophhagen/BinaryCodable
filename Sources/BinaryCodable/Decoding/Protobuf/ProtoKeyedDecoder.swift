import Foundation

final class ProtoKeyedDecoder<Key>: AbstractDecodingNode, KeyedDecodingContainerProtocol where Key: CodingKey {

    let content: [DecodingKey: Data]

    init(data: Data, codingPath: [CodingKey], options: Set<CodingOption>) throws {
        let decoder = DataDecoder(data: data)
        var content = [DecodingKey: [Data]]()
        while decoder.hasMoreBytes {
            let (key, dataType) = try DecodingKey.decodeProto(from: decoder)

            let data = try decoder.getData(for: dataType)

            guard content[key] != nil else {
                content[key] = [data]
                continue
            }
            content[key]!.append(data)
        }
        self.content = content.mapValues { parts in
            guard parts.count > 1 else {
                return parts[0]
            }
            /// We need to prepend the length of each element
            /// so that `KeyedEncoder` can decode it correctly
            return parts.map {
                $0.count.variableLengthEncoding + $0
            }.joinedData
        }
        super.init(codingPath: codingPath, options: options)
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
            throw BinaryDecodingError.missingDataForKey(key)
        }
        return data
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        !contains(key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        let data = try getData(forKey: key)
        if let _ = type as? DecodablePrimitive.Type {
            if let ProtoType = type as? ProtobufDecodable.Type {
                return try ProtoType.init(fromProtobuf: data) as! T
            }
            throw BinaryDecodingError.unsupportedType(type)
        } else if type is AnyDictionary.Type {
            let node = ProtoDictDecodingNode(data: data, codingPath: codingPath, options: options)
            return try T.init(from: node)
        }
        let node = ProtoDecodingNode(data: data, codingPath: codingPath, options: options)
        return try T.init(from: node)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let data = try getData(forKey: key)
        let container = try ProtoKeyedDecoder<NestedKey>(data: data, codingPath: codingPath, options: options)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let data = try getData(forKey: key)
        return try ProtoUnkeyedDecoder(data: data, codingPath: codingPath, options: options)
    }

    func superDecoder() throws -> Decoder {
        throw BinaryDecodingError.superNotSupported
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        throw BinaryDecodingError.superNotSupported
    }
}
