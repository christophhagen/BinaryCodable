import XCTest
import BinaryCodable

final class FileDecodingTests: XCTestCase {

    private let fileUrl: URL = {
        if #available(macOS 13.0, *) {
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
        if #available(macOS 13.0, *) {
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
        struct Test: Codable, Equatable {
            let a: Int
            let b: String
        }


        let encoder = BinaryStreamEncoder<Test>()

        try (0..<1000).forEach { number in
            let data = try encoder.encode(Test(a: number, b: "\(number)"))

        }
    }
}
