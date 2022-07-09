import Foundation

/**
 The default key used to encode `super` into a keyed container.

 The key uses either the string key `super`, or the integer key `0`.
 */
struct SuperEncoderKey: CodingKey {

    /**
     Create a new super encoding key.

     The string value of the key will be set to `super`
     - Parameter stringValue: This parameter is ignored.
     */
    init?(stringValue: String) {
        
    }

    /**
     Create a new super encoding key.

     The integer value of the key will be set to `0`
     - Parameter intValue: This parameter is ignored.
     */
    init?(intValue: Int) {
        
    }

    /**
     Create a new super encoding key.
     */
    init() { }

    /// The string value of the coding key (`super`)
    var stringValue: String {
        "super"
    }

    /// The integer value of the coding key (`0`)
    var intValue: Int? {
        0
    }
}
