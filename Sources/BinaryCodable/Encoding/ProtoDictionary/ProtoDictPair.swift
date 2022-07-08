import Foundation

struct ProtoDictPair {

    let key: NonNilEncodingContainer

    let value: NonNilEncodingContainer
}

extension ProtoDictPair: NonNilEncodingContainer {

    var data: Data {
        key.encodeWithKey(IntKeyWrapper(value: 1))
        + value.encodeWithKey(IntKeyWrapper(value: 2))
    }

    var dataType: DataType {
        .variableLength
    }
}
