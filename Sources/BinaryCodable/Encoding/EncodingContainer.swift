import Foundation

protocol EncodingContainer {
    
    var data: Data { get }
    
    var dataType: DataType { get }

    var isNil: Bool { get }
}

extension EncodingContainer {
    
    var dataWithLengthInformationIfRequired: Data {
        guard dataType == .variableLength else {
            return data
        }
        let data = self.data
        return data.count.variableLengthEncoding + data
    }
}

extension EncodingContainer {

    var isNil: Bool {
        // Default implementation for most containers
        false
    }
}
