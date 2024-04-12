import Foundation

@propertyWrapper
public struct Packed<WrappedValue> where WrappedValue: RangeReplaceableCollection {

    /// The sequence wrapped in the packed container
    public var wrappedValue: WrappedValue

    /**
     Wrap an integer value in a fixed-size container
     - Parameter wrappedValue: The sequence to wrap
     */
    public init(wrappedValue: WrappedValue) {
        self.wrappedValue = wrappedValue
    }
}

extension Packed: EncodablePrimitive where WrappedValue.Element: PackedEncodable {

    /**
     Encode the wrapped value to binary data compatible with the protobuf encoding.
     - Returns: The binary data in host-independent format.
     */
    var encodedData: Data {
        wrappedValue.mapAndJoin {
            let data = $0.encodedData
            return data.count.variableLengthEncoding + data
        }
    }
}

extension Packed: DecodablePrimitive where WrappedValue.Element: PackedDecodable {

    public init(data: Data) throws {
        var index = data.startIndex
        var elements = [WrappedValue.Element]()
        while !data.isAtEnd(at: index) {
            let element = try WrappedValue.Element.init(data: data, index: &index)
            elements.append(element)
        }
        self.wrappedValue = WrappedValue.init(elements)
    }
}

extension Packed: Encodable where WrappedValue.Element: Encodable {

    /**
     Encode the wrapped value transparently to the given encoder.
     - Parameter encoder: The encoder to use for encoding.
     - Throws: Errors from the decoder when attempting to encode a value in a single value container.
     */
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        for element in wrappedValue {
            try container.encode(element)
        }
    }
}

extension Packed: Decodable where WrappedValue.Element: Decodable {
    /**
     Decode a wrapped value from a decoder.
     - Parameter decoder: The decoder to use for decoding.
     - Throws: Errors from the decoder when reading a single value container or decoding the wrapped value from it.
     */
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var elements = WrappedValue()
        while !container.isAtEnd {
            let next = try container.decode(WrappedValue.Element.self)
            elements.append(next)
        }
        self.wrappedValue = elements
    }
}
