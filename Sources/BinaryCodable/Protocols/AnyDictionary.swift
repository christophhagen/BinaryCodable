import Foundation

/**
 An abstract Dictionary, without any `self` requirements.

 This protocol is only adopted by `Dictionary`, and used to correctly encode and decode dictionaries for Protobuf-compatible encoding.
 */
protocol AnyDictionary {

}

extension Dictionary: AnyDictionary {

}
