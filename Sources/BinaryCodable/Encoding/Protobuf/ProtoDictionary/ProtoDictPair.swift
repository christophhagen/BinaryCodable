import Foundation

struct ProtoDictPair {

    let key: NonNilEncodingContainer

    let value: NonNilEncodingContainer
}

extension ProtoDictPair: NonNilEncodingContainer {

    var data: Data {
        key.encodeWithKey(try! IntKeyWrapper(value: 1))
        + value.encodeWithKey(try! IntKeyWrapper(value: 2))
    }

    var dataType: DataType {
        .variableLength
    }

    var isEmpty: Bool {
        false
    }
}
