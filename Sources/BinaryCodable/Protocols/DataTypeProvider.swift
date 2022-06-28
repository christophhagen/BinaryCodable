import Foundation

protocol DataTypeProvider {

    static var dataType: DataType { get }
}

extension DataTypeProvider {

    var dataType: DataType {
        Self.dataType
    }
}
