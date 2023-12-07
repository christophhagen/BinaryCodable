import Foundation

/**
 Decode elements from a byte stream.

 Stream decoding can be used when either the data is not regularly available completely (e.g. when loading data over a network connection),
 or when the binary data should not be loaded into memory all at once (e.g. when parsing a file).

 Each stream decoder handles only elements of a single type.
 The decoder can then attempt to read elements whenever new data is received, until a complete element can be decoded.
 Buffering is handled internally, freeing the stream provider from this responsibility.
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
    
    
    /**
     Add new data to the internal buffer without attempting to decode elements.
     - Parameter data: The datat to append to the internal buffer.
     */
    public func add(_ data: Data) {
        buffer.addToBuffer(data)
    }
    
    /// The number of currently buffered bytes.
    var numberOfBytesInBuffer: Int {
        buffer.unusedBytes
    }
    
    /**
     Discard bytes from the currently remaining bytes.
     
     This function can be used when attempting to correct a corrupted stream. It may be possible to drop bytes from the buffer until a new valid element can be decoded.
     - Note: If the stream data is corrupted, then decoding elements from the middle of the stream may lead to unexpected results.
     It's possible to decode bogus elements when starting at the wrong position, or the stream decoder could get stuck waiting for a large number of bytes.
     - Parameter count: The number of bytes to remove
     - Returns: The number of bytes removed.
     */
    @discardableResult
    public func discardBytes(_ count: Int) -> Int {
        buffer.discard(bytes: count)
    }

    // MARK: Decoding

    /**
     Read elements from the stream until no more bytes are available.

     - Parameter returnElementsBeforeError: If set to `true`,
     then all successfully decoded elements will be returned if an error occurs. Defaults to `false`
     - Throws: Decoding errors of type ``DecodingError``.
     - Note: This function is deprecated. If you want to decode elements, use ``decodeElements()``, or use ``decodeElementsUntilError()``, if you expect errors in the data stream.
     */
    @available(*, deprecated, message: "Use add() and decodeElementsUntilError() or decodeElements() instead.")
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
    
    /**
     Read elements from the stream until an error occurs.
     
     This function may be useful if the data is corrupted. The readable elements can be decoded until a decoding error is encountered.
     - Returns: The elements that could be decoded until an error occured or the buffer was insufficient, and the decoding error, if one occured.
     */
    public func decodeElementsUntilError() -> (elements: [Element], error: Error?) {
        var results = [Element]()
        while buffer.hasMoreBytes {
            do {
                guard let element = try decodeElement() else {
                    return (results, nil)
                }
                results.append(element)
            } catch {
                return (results, error)
            }
        }
        return (results, nil)
    }
    
    /**
     Read elements until no more data is available.
     
     - Note: If a decoding error occurs within the data, then the elements successfully decoded before are lost.
     If you expect decoding errors to occur, either decode elements individually using ``decodeElement()``, or use ``decodeElementsUntilError()``.
     - Returns: The elements that could be decoded with the available data.
     - Throws: Decoding errors of type ``DecodingError``.
     */
    public func decodeElements() throws -> [Element] {
        var results = [Element]()
        while buffer.hasMoreBytes {
            guard let element = try decodeElement() else {
                return results
            }
            results.append(element)
        }
        return results
    }

    /**
     Attempt to decode a single element from the stream.
     
     If insufficient bytes are available, then no element is returned, and the internal buffer is kept intact.
     - Returns: The decoded element, if enough bytes are available.
     - Throws: Decoding errors of type ``DecodingError``.
     */
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
