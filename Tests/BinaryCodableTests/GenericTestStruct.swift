import Foundation

/**
 A struct to provide custom encode and decode functions via static properties
 for testing. Reduces the need to create full struct definitions when testing custom
 encoding and decoding routines
 */
struct GenericTestStruct: Codable, Equatable {

    init() {

    }

    init(from decoder: Decoder) throws {
        try GenericTestStruct.decodingRoutine(decoder)
    }

    func encode(to encoder: Encoder) throws {
        try GenericTestStruct.encodingRoutine(encoder)
    }

    private static nonisolated(unsafe) var _encodingRoutine: (Encoder) throws -> Void = { _ in }

    private static nonisolated(unsafe) var _decodingRoutine: (Decoder) throws -> Void = { _ in }

    private static let encodeSemaphore = DispatchSemaphore(value: 1)

    static var encodingRoutine: (Encoder) throws -> Void {
        get {
            encodeSemaphore.wait()
            let value = _encodingRoutine
            encodeSemaphore.signal()
            return value
        }
        set {
            encodeSemaphore.wait()
            _encodingRoutine = newValue
            encodeSemaphore.signal()
        }
    }

    private static let decodeSemaphore = DispatchSemaphore(value: 1)

    static var decodingRoutine: (Decoder) throws -> Void {
        get {
            decodeSemaphore.wait()
            let value = _decodingRoutine
            decodeSemaphore.signal()
            return value
        }
        set {
            decodeSemaphore.wait()
            _decodingRoutine = newValue
            decodeSemaphore.signal()
        }
    }

    static func encode(_ block: @escaping (Encoder) throws -> Void) {
        encodingRoutine = block
    }

    static func decode(_ block: @escaping (Decoder) throws -> Void) {
        decodingRoutine = block
    }
}

