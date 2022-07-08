import Foundation

protocol NonNilEncodingContainer {
    
    var data: Data { get }
    
    var dataType: DataType { get }

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data
}

protocol EncodingContainer: NonNilEncodingContainer {

    var isNil: Bool { get }
}

extension NonNilEncodingContainer {
    
    var dataWithLengthInformationIfRequired: Data {
        guard dataType == .variableLength else {
            return data
        }
        return dataWithLengthInformation
    }

    var dataWithLengthInformation: Data {
        let data = self.data
        return data.count.variableLengthEncoding + data
    }


    func encodeWithKey(_ key: CodingKeyWrapper) -> Data {
        key.encode(for: dataType) + dataWithLengthInformationIfRequired
    }
}

extension EncodingContainer {

    var isNil: Bool {
        // Default implementation for most containers
        false
    }
}
