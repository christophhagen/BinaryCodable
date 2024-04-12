import Foundation

extension Array: EncodablePrimitive where Element: PackedEncodable {

    var encodedData: Data {
        mapAndJoin { $0.encodedData }
    }
}

extension Array: DecodablePrimitive where Element: PackedDecodable {

    init(data: Data) throws {
        var index = data.startIndex
        var elements = [Element]()
        while !data.isAtEnd(at: index) {
            let element = try Element.init(data: data, index: &index)
            elements.append(element)
        }
        self.init(elements)
    }
}
