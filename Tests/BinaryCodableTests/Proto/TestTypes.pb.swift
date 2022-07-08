// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: TestTypes.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

struct SimpleStruct {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Equivalent to Swift `Int64`
  var integer64: Int64 = 0

  /// Equivalent to Swift `String`
  var text: String = String()

  /// Equivalent to Swift `Data`
  var data: Data = Data()

  /// Equivalent to Swift `[UInt32]`
  var intArray: [UInt32] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct WrappedContainer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Equivalent to Swift `FixedSize<Int32>`
  var fourByteInt: Int32 = 0

  /// Equivalent to Swift `FixedSize<UInt32>`
  var fourByteUint: UInt32 = 0

  /// Equivalent to Swift `FixedSize<Int64>`
  var eightByteInt: Int64 = 0

  /// Equivalent to Swift `FixedSize<UInt64>`
  var eightByteUint: UInt64 = 0

  /// Equivalent to Swift `SignedValue<Int32>`
  var signed32: Int32 = 0

  /// Equivalent to Swift `SignedValue<Int64>`
  var signed64: Int64 = 0

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct Outer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var inner: SimpleStruct {
    get {return _inner ?? SimpleStruct()}
    set {_inner = newValue}
  }
  /// Returns true if `inner` has been explicitly set.
  var hasInner: Bool {return self._inner != nil}
  /// Clears the value of `inner`. Subsequent reads from it will return its default value.
  mutating func clearInner() {self._inner = nil}

  var more: SimpleStruct {
    get {return _more ?? SimpleStruct()}
    set {_more = newValue}
  }
  /// Returns true if `more` has been explicitly set.
  var hasMore: Bool {return self._more != nil}
  /// Clears the value of `more`. Subsequent reads from it will return its default value.
  mutating func clearMore() {self._more = nil}

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}

  fileprivate var _inner: SimpleStruct? = nil
  fileprivate var _more: SimpleStruct? = nil
}

struct Outer2 {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var values: [SimpleStruct] = []

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

/// A container to test different map types
struct MapContainer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var x: Dictionary<String,Data> = [:]

  var y: Dictionary<UInt32,String> = [:]

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension SimpleStruct: @unchecked Sendable {}
extension WrappedContainer: @unchecked Sendable {}
extension Outer: @unchecked Sendable {}
extension Outer2: @unchecked Sendable {}
extension MapContainer: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

extension SimpleStruct: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "SimpleStruct"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "integer64"),
    2: .same(proto: "text"),
    3: .same(proto: "data"),
    4: .same(proto: "intArray"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt64Field(value: &self.integer64) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.text) }()
      case 3: try { try decoder.decodeSingularBytesField(value: &self.data) }()
      case 4: try { try decoder.decodeRepeatedUInt32Field(value: &self.intArray) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.integer64 != 0 {
      try visitor.visitSingularInt64Field(value: self.integer64, fieldNumber: 1)
    }
    if !self.text.isEmpty {
      try visitor.visitSingularStringField(value: self.text, fieldNumber: 2)
    }
    if !self.data.isEmpty {
      try visitor.visitSingularBytesField(value: self.data, fieldNumber: 3)
    }
    if !self.intArray.isEmpty {
      try visitor.visitPackedUInt32Field(value: self.intArray, fieldNumber: 4)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: SimpleStruct, rhs: SimpleStruct) -> Bool {
    if lhs.integer64 != rhs.integer64 {return false}
    if lhs.text != rhs.text {return false}
    if lhs.data != rhs.data {return false}
    if lhs.intArray != rhs.intArray {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension WrappedContainer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "WrappedContainer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "fourByteInt"),
    2: .same(proto: "fourByteUInt"),
    3: .same(proto: "eightByteInt"),
    4: .same(proto: "eightByteUInt"),
    5: .same(proto: "signed32"),
    6: .same(proto: "signed64"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularSFixed32Field(value: &self.fourByteInt) }()
      case 2: try { try decoder.decodeSingularFixed32Field(value: &self.fourByteUint) }()
      case 3: try { try decoder.decodeSingularSFixed64Field(value: &self.eightByteInt) }()
      case 4: try { try decoder.decodeSingularFixed64Field(value: &self.eightByteUint) }()
      case 5: try { try decoder.decodeSingularSInt32Field(value: &self.signed32) }()
      case 6: try { try decoder.decodeSingularSInt64Field(value: &self.signed64) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.fourByteInt != 0 {
      try visitor.visitSingularSFixed32Field(value: self.fourByteInt, fieldNumber: 1)
    }
    if self.fourByteUint != 0 {
      try visitor.visitSingularFixed32Field(value: self.fourByteUint, fieldNumber: 2)
    }
    if self.eightByteInt != 0 {
      try visitor.visitSingularSFixed64Field(value: self.eightByteInt, fieldNumber: 3)
    }
    if self.eightByteUint != 0 {
      try visitor.visitSingularFixed64Field(value: self.eightByteUint, fieldNumber: 4)
    }
    if self.signed32 != 0 {
      try visitor.visitSingularSInt32Field(value: self.signed32, fieldNumber: 5)
    }
    if self.signed64 != 0 {
      try visitor.visitSingularSInt64Field(value: self.signed64, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: WrappedContainer, rhs: WrappedContainer) -> Bool {
    if lhs.fourByteInt != rhs.fourByteInt {return false}
    if lhs.fourByteUint != rhs.fourByteUint {return false}
    if lhs.eightByteInt != rhs.eightByteInt {return false}
    if lhs.eightByteUint != rhs.eightByteUint {return false}
    if lhs.signed32 != rhs.signed32 {return false}
    if lhs.signed64 != rhs.signed64 {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Outer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "Outer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "inner"),
    2: .same(proto: "more"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._inner) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._more) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._inner {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try { if let v = self._more {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Outer, rhs: Outer) -> Bool {
    if lhs._inner != rhs._inner {return false}
    if lhs._more != rhs._more {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Outer2: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "Outer2"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "values"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeRepeatedMessageField(value: &self.values) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.values.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.values, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Outer2, rhs: Outer2) -> Bool {
    if lhs.values != rhs.values {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension MapContainer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "MapContainer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "x"),
    2: .same(proto: "y"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString,SwiftProtobuf.ProtobufBytes>.self, value: &self.x) }()
      case 2: try { try decoder.decodeMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufUInt32,SwiftProtobuf.ProtobufString>.self, value: &self.y) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.x.isEmpty {
      try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufString,SwiftProtobuf.ProtobufBytes>.self, value: self.x, fieldNumber: 1)
    }
    if !self.y.isEmpty {
      try visitor.visitMapField(fieldType: SwiftProtobuf._ProtobufMap<SwiftProtobuf.ProtobufUInt32,SwiftProtobuf.ProtobufString>.self, value: self.y, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: MapContainer, rhs: MapContainer) -> Bool {
    if lhs.x != rhs.x {return false}
    if lhs.y != rhs.y {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
