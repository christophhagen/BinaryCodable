import Foundation

/**
 Encode a stream of elements to a binary file.

 This class complements ``BinaryStreamEncoder`` to directly write encoded elements to a file.
 */
public final class BinaryFileEncoder<Element> where Element: Encodable {

    private let handle: FileHandle

    private let stream: BinaryStreamEncoder<Element>

    /**
     Create a new file encoder.
     - Note: The file will be created, if it does not exist.
     If it exists, then the new elements will be appended to the end of the file.
     - Parameter url: The url to the file.
     - Parameter encoder: The encoder to use for each element.
     - Throws: Throws an error if the file could not be accessed or created.
     */
    public init(fileAt url: URL, encoder: BinaryEncoder = .init()) throws {
        if !url.exists {
            try url.createEmptyFile()
        }
        let handle = try FileHandle(forWritingTo: url)
        if #available(macOS 10.15.4, iOS 13.4, watchOS 6.2, tvOS 13.4, *) {
            try handle.seekToEnd()
        } else {
            handle.seekToEndOfFile()
        }
        self.handle = handle
        self.stream = .init(encoder: encoder)
    }

    deinit {
        try? close()
    }

    /**
     Close the file.

     - Note: After closing the file, the encoder can no longer write elements, which will result in an error or an exception.
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

    /**
     Write a single element to the file.
     - Note: This function will throw an error or exception if the file handle has already been closed.
     - Parameter element: The element to encode.
     - Throws: Errors of type ``EncodingError``
     */
    public func write(_ element: Element) throws {
        let data = try stream.encode(element)
        if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
            try handle.write(contentsOf: data)
        } else {
            handle.write(data)
        }
    }

    /**
     Write a sequence of elements to the file.

     This is a convenience function calling `write(_ element:)` for each element of the sequence in order.

     - Parameter sequence: The sequence to encode
     - Throws: Errors of type ``EncodingError``
     */
    public func write<S>(contentsOf sequence: S) throws where S: Sequence, S.Element == Element {
        try sequence.forEach(write)
    }
}

private extension URL {

    var exists: Bool {
        /*
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return FileManager.default.fileExists(atPath: path())
        }
         */
        return FileManager.default.fileExists(atPath: path)
    }

    func createEmptyFile() throws {
        try Data().write(to: self)
    }
}
