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

    /**
     The buffer storing the data while elements are being decoded.
     */
    private var buffer = Data()

    /**
     The length of the next element.

     This property is `nil`, while the length is being decoded.
     */
    private var lengthOfCurrentElement: Int?

    /// The current length of the next element, while decoding the bytes
    private var currentLength: UInt64 = 0

    /// The number of length bytes already decoded
    private var numberOfLengthBytes = 0

    /**
     Create a stream decoder.

     - Parameter decoder: The decoder to use for decoding.
     */
    public init(decoder: BinaryDecoder = .init()) {
        self.decoder = decoder
    }

    // MARK: Buffer operations

    private var isAtEnd: Bool {
        buffer.isEmpty
    }

    private func nextByte() -> UInt8? {
        buffer.popFirst()
    }

    private func nextBytes(_ count: Int) -> Data {
        let data = buffer[buffer.startIndex..<buffer.startIndex+count]
        buffer.removeFirst(count)
        return data
    }

    /**
     Add new data to the internal buffer without attempting to decode elements.
     - Parameter data: The datat to append to the internal buffer.
     */
    public func add(_ data: Data) {
        buffer.append(data)
    }

    /// The number of currently buffered bytes.
    private var numberOfBytesInBuffer: Int {
        buffer.count
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
        let oldCount = buffer.count
        buffer = buffer.dropFirst(count)
        return oldCount - buffer.count
    }

    // MARK: Decoding

    /**
     Read elements from the stream until an error occurs.

     This function may be useful if the data is corrupted. The readable elements can be decoded until a decoding error is encountered.
     - Returns: The elements that could be decoded until an error occured or the buffer was insufficient, and the decoding error, if one occured.
     */
    public func decodeElementsUntilError() -> (elements: [Element], error: Error?) {
        var results = [Element]()
        while !buffer.isEmpty {
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
     - Throws: Decoding errors of type `DecodingError`.
     */
    public func decodeElements() throws -> [Element] {
        var results = [Element]()
        while !isAtEnd {
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
     - Throws: Decoding errors of type `DecodingError`.
     */
    public func decodeElement() throws -> Element? {
        if let length = lengthOfCurrentElement {
            return try decodeElement(length: length)
        }

        // Start by checking the nil bit and decode the first byte of the length
        if numberOfLengthBytes == 0 {
            guard let first = nextByte() else {
                return nil // Wait for first byte
            }

            // Check the nil indicator bit
            guard first & 0x01 == 0 else {
                // Decode a nil element (throws an error if the element can't be nil)
                let node = try DecodingNode(data: nil, parentDecodedNil: true, codingPath: [], userInfo: decoder.userInfo)
                return try Element.init(from: node)
                // No need to reset any state
            }

            // Ensure that the decoding of the first byte is skipped until a full element is decoded
            numberOfLengthBytes = 1

            // Check if more length bytes are needed
            if first & 0x80 == 0 {
                // Finished with the length
                return try decodeElement(length: Int(first >> 1))
            }
            // Start the length decoding
            currentLength = UInt64(first)
        }

        // Continue decoding the length
        while numberOfLengthBytes < 8 {
            guard let nextByte = nextByte() else {
                return nil // Wait for more bytes
            }
            // Insert the last 7 bit of the byte at the end
            currentLength += UInt64(nextByte & 0x7F) << (numberOfLengthBytes * 7)
            numberOfLengthBytes += 1
            // Check if an additional byte is coming
            guard nextByte & 0x80 > 0 else {
                // Finished decoding the length
                return try decodeElement(length: Int(currentLength >> 1))
            }
        }
        // Decode the last byte
        guard let nextByte = nextByte() else {
            return nil // Wait for more bytes
        }
        // The 9th byte has no next-byte bit, so all 8 bits are used
        currentLength += UInt64(nextByte) << 56
        return try decodeElement(length: Int(currentLength >> 1))
    }

    private func decodeElement(length: Int) throws -> Element? {
        guard numberOfBytesInBuffer >= length else {
            // Wait for enough bytes to decode the next element
            self.lengthOfCurrentElement = length
            return nil
        }
        let data = nextBytes(length)

        // Reset the state to begin with length/nil decoding
        self.lengthOfCurrentElement = nil
        self.currentLength = 0
        self.numberOfLengthBytes = 0

        let node = try DecodingNode(data: data, parentDecodedNil: true, codingPath: [], userInfo: decoder.userInfo)
        return try Element.init(from: node)
    }

    private func corrupted(_ message: String) -> DecodingError {
        return .corrupted(message, codingPath: [])
    }
}
