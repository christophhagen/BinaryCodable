import Foundation

/// A signed integer which can be forced to use zig-zag encoding.
public protocol SignedValueCompatible {

    var positiveProtoType: String { get }
}
