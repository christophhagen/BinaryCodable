import Foundation

struct ProtoDictPair {

    let key: EncodingContainer

    let value: EncodingContainer
}

extension ProtoDictPair: EncodingContainer {

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
