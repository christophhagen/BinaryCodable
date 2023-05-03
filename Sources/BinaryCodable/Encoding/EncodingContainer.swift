import Foundation

protocol EncodingContainer {
    
    var data: Data { get }
    
    var dataType: DataType { get }

    func encodeWithKey(_ key: CodingKeyWrapper) -> Data

    var isEmpty: Bool { get }

    var dataWithLengthInformationIfRequired: Data { get }
}

extension EncodingContainer {
    
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
