import Foundation

final class ProtoDictKeyedDecoder<Key>: ProtoKeyedDecoder<Key> where Key: CodingKey {

    override init(data: Data, path: [CodingKey], info: UserInfo) throws {
        let decoder = DataDecoder(data: data)
        var content = [DecodingKey: [Data]]()
        while decoder.hasMoreBytes {
            let pairData = try decoder.getData(for: .variableLength)
            let pairDecoder = DataDecoder(data: pairData)
            let (keyField, keyDataType) = try DecodingKey.decodeProto(from: pairDecoder)
            guard case .intKey(1) = keyField else {
                throw ProtobufDecodingError.unexpectedDictionaryKey
            }
            let keyData = try pairDecoder.getData(for: keyDataType)
            let key: DecodingKey
            switch keyDataType {
            case .variableLengthInteger:
                let value = try Int(decodeFrom: keyData)
                key = .intKey(value)
            case .variableLength:
                let value = try String(decodeFrom: keyData)
                key = .stringKey(value)
            default:
                throw ProtobufDecodingError.unexpectedDictionaryKey
            }

            let (valueField, valueDataType) = try DecodingKey.decodeProto(from: pairDecoder)
            guard case .intKey(2) = valueField else {
                throw ProtobufDecodingError.unexpectedDictionaryKey
            }
            let valueData = try pairDecoder.getData(for: valueDataType)
            guard content[key] != nil else {
                content[key] = [valueData]
                continue
            }
            content[key]!.append(valueData)
        }
        let mapped = content.mapValues { parts -> Data in
            guard parts.count > 1 else {
                return parts[0]
            }
            /// We need to prepend the length of each element
            /// so that `KeyedEncoder` can decode it correctly
            return parts.map {
                $0.count.variableLengthEncoding + $0
            }.joinedData
        }
        super.init(content: mapped, path: path, info: info)
    }
}
