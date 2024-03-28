import Foundation

/**
 Add conformance to this protocol to enums which should be encoded as Protobuf `Oneof` values.
 
 Conform a suitable enum to the `ProtobufOneOf` protocol to indicate that it should be encoded as single value.
 
 The enum must have exactly one associated value for each case, and the integer keys must not overlap with the ones defined for the enclosing struct.
 ```swift
 struct Test: Codable {

    // The oneof field
    let alternatives: OneOf
 
    // The OneOf definition
    enum OneOf: Codable, ProtobufOneOf {
        case integer(Int)
        case string(String)
         
        // Field values, must not overlap with `Test.CodingKeys`
        enum CodingKeys: Int, CodingKey {
            case integer = 1
            case string = 2
        }
    }
     
     enum CodingKeys: Int, CodingKey {
        // The field id of the Oneof field is not used
         case alternatives = 123456
     }
 }
 ```
 
 See: [Protocol Buffer Language Guide: Oneof](https://developers.google.com/protocol-buffers/docs/proto3#oneof) and [Swift Protobuf: Oneof Fields](https://github.com/apple/swift-protobuf/blob/main/Documentation/API.md#oneof-fields)
 */
public protocol ProtobufOneOf { }
