import Foundation

/**
 Encode elements sequentially into a binary data stream.

 A stream encoder is used to encode individual elements of the same type to a continuous binary stream,
 which can be decoded sequentially.

 The encoding behaviour is different to ``BinaryEncoder``, where the full data must be present to successfully decode.
 Additional information is embedded into the stream to facilitate this behaviour.
 The binary data produced by a stream encoder is not compatible with ``BinaryDecoder`` and can only be decoded using
 ``BinaryStreamDecoder``.

 The special data format of an encoded stream also allows joining sequences of encoded data, where:
 `encode([a,b]) + encode([c,d]) == encode([a,b,c,d])` and `decode(encode([a]) + encode([b])) == [a,b]`

 Example:
 ```
 let encoder = BinaryStreamEncoder<Int>()
 let encoded1 = try encoder.encode(1)

 let decoder = BinaryStreamDecoder<Int>()
 let decoded1 = try decoder.decode(encoded1)
 print(decoded1) // [1]

 let encoded2 = try encoder.encode(contentsOf: [2,3])
 let decoded2 = try decoder.decode(encoded2)
 print(decoded2) // [2,3]
 ```

 - Note: Stream decoders always work on a single type, because no type information is encoded into the data.
 */
public final class BinaryStreamEncoder<Element> where Element: Encodable {

    /**
     The encoder used to encode the individual elements.
     - Note: This property is `private` to prevent errors through reconfiguration between element encodings.
     */
    private let encoder: BinaryEncoder

    /**
     Create a new stream encoder.

     - Note: The encoder should never be reconfigured after being passed to this function,
     to prevent decoding errors due to mismatching binary formats.
     - Parameter encoder: The encoder to use for the individual elements.
     */
    public init(encoder: BinaryEncoder = .init()) {
        self.encoder = encoder
    }

    /**
     Encode an element for the data stream.

     Call this function to convert an element into binary data whenever new elements are available.
     The data provided as the result of this function should be processed (e.g. stored or transmitted) while conserving the
     order of the chunks, so that decoding can work reliably.

     Pass the encoded data back into an instance of ``BinaryStreamDecoder`` to convert each chunk back to an element.

     - Note: Data encoded by this function can only be decoded by an appropriate ``BinaryStreamDecoder``.
     Decoding using a simple ``BinaryDecoder`` will not be successful.
     - Parameter element: The element to encode.
     - Returns: The next chunk of the encoded binary stream.
     - Throws: Errors of type ``BinaryEncodingError``
     */
    public func encode(_ element: Element) throws -> Data {
        guard let optional = element as? AnyOptional else {
            return try encoder.encodeForStream(element)
        }
        guard optional.isNil else {
            let data = try encoder.encodeForStream(element)
            return Data([1]) + data
        }
        return Data([0])
    }

    /**
     Encode a sequence of elements.

     This function performs multiple calls to ``encode(_:)`` to convert all elements of the sequence, and then returns the joined data.
     - Parameter sequence: The sequence of elements to encode
     - Returns: The binary data of the encoded sequence elements
     - Throws: Errors of type ``BinaryEncodingError``
     */
    public func encode<S>(contentsOf sequence: S) throws -> Data where S: Sequence, S.Element == Element {
        try sequence.map(encode).joinedData
    }
}
