import Foundation

/// A type that can be encoded and decoded without length information
typealias PackedCodable = PackedEncodable & PackedDecodable
