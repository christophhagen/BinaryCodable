import Foundation

class AbstractNode {

    let codingPath: [CodingKey]

    let options: Set<CodingOption>

    var userInfo: [CodingUserInfoKey : Any] {
        options.reduce(into: [:]) { $0[$1.infoKey] = true }
    }

    init(codingPath: [CodingKey], options: Set<CodingOption>) {
        self.codingPath = codingPath
        self.options = options
    }

    /**
     Force the encoder to encode using a protobuf-compatible format.

     Enabling this option provoides limited compatibility with Google's Protocol Buffers.

     Encoding unsupported data types causes `BinaryEncodingError.notProtobufCompatible` errors.
     */
    var forceProtobufCompatibility: Bool {
        options.contains(.protobufCompatibility)
    }

    func failIfProto(_ reason: String) {
        guard forceProtobufCompatibility else {
            return
        }
        fatalError(reason)
    }
}
