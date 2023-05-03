import Foundation

func wrapError<T>(path: [CodingKey], _ block: () throws -> T) rethrows -> T {
    do {
        return try block()
    } catch let error as EncodingError {
        switch error {
        case .invalidValue(let any, let context):
            let newContext = EncodingError.Context(
                codingPath: path + context.codingPath,
                debugDescription: context.debugDescription,
                underlyingError: context.underlyingError)
            throw EncodingError.invalidValue(any, newContext)
        @unknown default:
            throw error
        }
    } catch let error {
        let context = EncodingError.Context(codingPath: path, debugDescription: "An unknown error occured", underlyingError: error)
        throw EncodingError.invalidValue("", context)
    }
}
