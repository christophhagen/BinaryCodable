import Foundation

public protocol ByteStreamProvider {

    func getBytes(_ count: Int) throws -> Data

    /**
     Provide the current byte without advancing to the next.
     */
    func lookAtCurrentByte() -> UInt8?

    func getAllData() throws -> Data

    var hasMoreBytes: Bool { get }
}

extension ByteStreamProvider {

    func getByte() throws -> UInt8 {
        let data = try getBytes(1)
        return data[data.startIndex]
    }

    func getDataOfVarint() throws -> Data {
        var result = [UInt8]()
        for _ in 0...7 {
            let byte = try getByte()
            result.append(byte)
            if byte & 0x80 == 0 {
                return Data(result)
            }
        }
        let byte = try getByte()
        result.append(byte)
        return Data(result)
    }

    func getVarint() throws -> Int {
        let data = try getDataOfVarint()
        return try .init(fromVarint: data)
    }

    func getData(for dataType: DataType) throws -> Data {
        switch dataType {
        case .variableLengthInteger:
            return try getDataOfVarint()
        case .byte:
            return try getBytes(1)
        case .twoBytes:
            return try getBytes(2)
        case .variableLength:
            let count = try getVarint()
            return try getBytes(count)
        case .fourBytes:
            return try getBytes(4)
        case .eightBytes:
            return try getBytes(8)
        }
    }
}
