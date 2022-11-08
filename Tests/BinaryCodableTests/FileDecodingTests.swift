import XCTest
import BinaryCodable

private struct Test: Codable, Equatable, CustomStringConvertible {
    let a: Int
    let b: String

    var description: String {
        b
    }
}

final class FileDecodingTests: XCTestCase {

    private let fileUrl: URL = {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return FileManager.default.temporaryDirectory.appending(path: "file", directoryHint: .notDirectory)
        } else {
            return FileManager.default.temporaryDirectory.appendingPathComponent("file")
        }
    }()

    override func setUp() {
        if hasFile {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }

    var hasFile: Bool {
        if #available(macOS 13.0, iOS 16.0, tvOS 16.0, watchOS 9.0, *) {
            return FileManager.default.fileExists(atPath: fileUrl.path())
        } else {
            return FileManager.default.fileExists(atPath: fileUrl.path)
        }
    }

    override func tearDown() {
        if hasFile {
            try? FileManager.default.removeItem(at: fileUrl)
        }
    }

    func testEncodeToFile() throws {
        let encoder = try BinaryFileEncoder<Test>(fileAt: fileUrl)

        let input = (0..<1000).map { Test(a: $0, b: "\($0)") }
        try encoder.write(contentsOf: input)
        try encoder.close()

        let decoder = try BinaryFileDecoder<Test>(fileAt: fileUrl)
        var decoded = [Test]()
        try decoder.read { element in
            decoded.append(element)
        }
        try decoder.close()
        
        XCTAssertEqual(input, decoded)
    }

    func testAddToExistingFile() throws {
        let input = (0..<1000).map { Test(a: $0, b: "\($0)") }

        // Write ten distinct times to file
        for i in 0..<10 {
            let encoder = try BinaryFileEncoder<Test>(fileAt: fileUrl)
            let part = input[(i*100)..<(i+1)*100]
            try encoder.write(contentsOf: part)
            try encoder.close()
        }

        // Decode all together
        let decoder = try BinaryFileDecoder<Test>(fileAt: fileUrl)
        var decoded = [Test]()
        try decoder.read { element in
            decoded.append(element)
        }
        try decoder.close()

        XCTAssertEqual(input, decoded)
    }

    func testReadUntilError() throws {
        let input = (0..<1000).map { Test(a: $0, b: "\($0)") }

        // Write first 500 elements
        do {
            let encoder = try BinaryFileEncoder<Test>(fileAt: fileUrl)
            let part = input[0..<500]
            try encoder.write(contentsOf: part)
            try encoder.close()
        }

        // Write invalid byte
        do {
            let handle = try FileHandle(forWritingTo: fileUrl)
            if #available(macOS 10.15.4, iOS 13.4, tvOS 13.4, watchOS 6.2, *) {
                try handle.seekToEnd()
                let data = Data([3])
                try handle.write(contentsOf: data)
            } else {
                handle.seekToEndOfFile()
                let data = Data([3])
                handle.write(data)
            }
        }

        // Write second 500 elements
        do {
            let encoder = try BinaryFileEncoder<Test>(fileAt: fileUrl)
            let part = input[500..<1000]
            try encoder.write(contentsOf: part)
            try encoder.close()
        }

        // Decode all together, which should fail
        do {
            let decoder = try BinaryFileDecoder<Test>(fileAt: fileUrl)
            defer { try? decoder.close() }
            let decoded = try decoder.readAll()
            print(decoded)
            XCTFail("Decoding should fail")
        } catch is BinaryDecodingError {

        }

        let decoder = try BinaryFileDecoder<Test>(fileAt: fileUrl)
        let decoded = decoder.readAllUntilError()
        try decoder.close()

        XCTAssertEqual(Array(input[0..<500]), decoded)
    }

    /**
     This test is currently not included, due to a bug in several `FileHandle` functions.
     Despite the documentation specifying that `write(contentsOf:)` throws, it actually
     produces an `NSException`, which can't be caught using try-catch. The test would therefore
     always fail.
     */
    /*
    func testWriteAfterClosing() throws {
        let encoder = try BinaryFileEncoder<Test>(fileAt: fileUrl)
        try encoder.write(.init(a: 0, b: "\(0)"))
        try encoder.close()
        do {
            try encoder.write(.init(a: 1, b: "\(1)"))
        } catch {
            print(type(of: error))
            print(error)
        }
    }
     */

    func testCloseFileTwice() throws {
        let encoder = try BinaryFileEncoder<Test>(fileAt: fileUrl)
        try encoder.close()
        try encoder.close()
        // File also closing during deinit
    }
}
