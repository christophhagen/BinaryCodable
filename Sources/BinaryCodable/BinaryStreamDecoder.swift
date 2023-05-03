import Foundation

/**
 Decode elements from a byte stream.

 Stream decoding can be used when either the data is not regularly available completely (e.g. when loading data over a network connection),
 or when the binary data should not be loaded into memory all at once (e.g. when parsing a file).

 Each stream decoder handles only elements of a single type.
 The elements are handed to a handler passed to the decoder upon initialization.
 The byte stream is managed by a provider also specified on object creation.
 The decoder can then attempt to read elements by reading bytes from the provider, until a complete element can be decoded.
 Buffering is handled internally, freeing the stream provider from this responsibility.
 Each completely decoded element is immediatelly passed to handler for further processing.
 */
public final class BinaryStreamDecoder<Element> where Element: Decodable {

    /**
     The decoder used to decode each element.
     */
    private let decoder: BinaryDecoder

    private let buffer: DataDecodingBuffer

    /**
     Create a stream decoder.

     - Parameter decoder: The decoder to use for decoding.
     */
    public init(decoder: BinaryDecoder = .init()) {
        self.decoder = decoder
        self.buffer = DataDecodingBuffer()
    }

    // MARK: Decoding

    /**
     Read elements from the stream until no more bytes are available.

     - Parameter returnElementsBeforeError: If set to `true`,
     then all successfully decoded elements will be returned if an error occurs. Defaults to `false`
     - Throws: Decoding errors of type ``DecodingError``.
     */
    public func decode(_ data: Data, returnElementsBeforeError: Bool = false) throws -> [Element] {
        buffer.addToBuffer(data)

        var results = [Element]()
        while buffer.hasMoreBytes {
            do {
                guard let element = try decodeElement() else {
                    return results
                }
                results.append(element)
            } catch {
                if returnElementsBeforeError {
                    return results
                }
                throw error
            }
        }
        return results
    }

    public func decodeElement() throws -> Element? {
        do {
            let element: Element = try decoder.decode(fromStream: buffer)
            // Remove the buffered data since element was correctly decoded
            buffer.discardUsedBufferData()
            return element
        } catch {
            if buffer.didExceedBuffer {
                // Insufficient data for now, reuse buffered bytes next time
                buffer.resetToBeginOfBuffer()
                return nil
            } else {
                // Remove the buffered data since element was correctly decoded
                buffer.discardUsedBufferData()
                throw error
            }
        }
    }
}
