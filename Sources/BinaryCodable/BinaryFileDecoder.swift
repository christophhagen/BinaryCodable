import Foundation

/**
 Read elements from a binary file.

 The decoder allows reading individual elements from a file without loading all file data to memory all at once.
 This decreases memory usage, which is especially useful for large files.
 Elements can also be read all at once, and corrupted files can be read until the first decoding error occurs.

 The class internally uses ``BinaryStreamDecoder`` to encode the individual elements,
 which can also be used independently to decode the data for more complex operations.

 **Handling corrupted data**

 The binary format does not necessarily allow detection of data corruption, and various errors can occur
 as the result of added, changed, or missing bytes. Additional measures should be applied if there is an
 increased risk of data corruption.

 As an example, consider the simple encoding of a `String` inside a `struct`, which consists of a `key`
 followed by the length of the string in bytes, and the string content. The length of the string is encoded using
 variable length encoding, so a single bit flip (in the MSB of the length byte) could result in a very large `length` being decoded,
 causing the decoder to wait for a very large number of bytes to decode the string. This simple error would cause much
 data to be skipped. At the same time, it is not possible to determine *with certainty* where the error occured.

 The library does therefore only provide hints about the decoding errors likely occuring from non-conformance to the binary format
 or version incompatibility, which are not necessarily the *true* causes of the failures when data corruption is present.


 - Note: This class is compatible with ``BinaryFileEncoder`` and ``BinaryStreamEncoder``,
 but not with the outputs of ``BinaryEncoder``.
 */
public final class BinaryFileDecoder<Element> where Element: Decodable {

    private let handle: FileHandle

    private let decoder: BinaryDecoder

    private let buffer: BinaryStreamBuffer

    /**
     Create a file decoder.

     The given file is opened, and decoding will begin at the start of the file.

     - Parameter url: The url of the file to read.
     - Parameter decoder: The decoder to use for decoding
     - Throws: An error, if the file handle could not be created.
     */
    public init(fileAt url: URL, decoder: BinaryDecoder = .init()) throws {
        let handle = try FileHandle(forReadingFrom: url)
        self.handle = handle
        self.decoder = decoder
        self.buffer = BinaryStreamBuffer(data: handle)
    }

    deinit {
        try? close()
    }

    /**
     Close the file.

     - Note: After closing the file, the decoder can no longer read elements, which will result in an error or an exception.
     - Throws: Currently throws a ObjC-style `Exception`, not an `Error`, even on modern systems.
     This is a bug in the Foundation framework.
     */
    public func close() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.4, watchOS 6.2, *) {
            try handle.close()
        } else {
            handle.closeFile()
        }
    }

    // MARK: Decoding

    /**
     Read all elements in the file, and handle each element using a closure.

     - Parameter elementHandler: The closure to handle each element as it is decoded.
     - Throws: Decoding errors of type ``BinaryDecodingError``.
     */
    public func read(_ elementHandler: (Element) -> Void) throws {
        while let element = try readElement() {
            elementHandler(element)
        }
    }

    /**
     Read all elements at once.
     - Returns: The elements decoded from the file.
     - Throws: Errors of type ``BinaryDecodingError``
     */
    public func readAll() throws -> [Element] {
        var result = [Element]()
        while let element = try readElement() {
            result.append(element)
        }
        return result
    }

    /**
     Read all elements at once, and ignore errors.

     This function reads elements until it reaches the end of the file or detects a decoding error.
     Any data after the first error will be ignored.
     - Returns: The elements successfully decoded from the file.
     */
    public func readAllUntilError() -> [Element] {
        var result = [Element]()
        while let element = try? readElement() {
            result.append(element)
        }
        return result
    }

    /**
     Read a single elements from the current position in the file.
     - Returns: The element decoded from the file, or `nil`, if no more data is available.
     - Throws: Errors of type ``BinaryDecodingError``
     */
    public func readElement() throws -> Element? {
        guard buffer.hasMoreBytes else {
            return nil
        }
        do {
            let element = try decodeNextElement()
            // Remove the buffered data since element was correctly decoded
            buffer.discardUsedBufferData()
            return element
        } catch {
            buffer.discardUsedBufferData()
            throw error
        }
    }

    private func decodeNextElement() throws -> Element {
        if Element.self is AnyOptional.Type {
            return try decodeOptional()
        } else {
            return try decodeNonOptional()
        }
    }

    private func decodeNonOptional() throws -> Element {
        return try decoder.decode(fromStream: buffer)
    }

    private func decodeOptional() throws -> Element {
        guard try buffer.getByte() > 0 else {
            return try decoder.decode(from: Data())
        }
        return try decodeNonOptional()
    }
}

extension FileHandle: BinaryStreamProvider {

    func getBytes(_ count: Int) throws -> Data {
        guard #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) else {
            let data = readData(ofLength: count)
            guard data.count == count else {
                throw BinaryDecodingError.prematureEndOfData
            }
            return data
        }
        guard let data = try read(upToCount: count) else {
            throw BinaryDecodingError.prematureEndOfData
        }
        return data
    }

    var hasMoreBytes: Bool {
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
            return moreBytesAvailable
        }

        if readData(ofLength: 1).first != nil {
            seek(toFileOffset: offsetInFile - 1)
            return true
        }
        return false
    }

    @available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *)
    private var moreBytesAvailable: Bool {
        if (try? read(upToCount: 1)?.first) != nil {
            try? seek(toOffset: offset() - 1)
            return true
        }
        return false
    }
}
