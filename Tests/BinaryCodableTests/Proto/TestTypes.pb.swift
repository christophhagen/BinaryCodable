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

struct PrimitiveTypesContainer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// Swift equivalent: `Double`
  var doubleValue: Double = 0

  /// Swift equivalent: `Float`
  var floatValue: Float = 0

  /// Swift equivalent: `Int32`
  var intValue32: Int32 = 0

  /// Swift equivalent: `Int64`
  var intValue64: Int64 = 0

  /// Swift equivalent: `UInt32`
  var uIntValue32: UInt32 = 0

  /// Swift equivalent: `UInt64`
  var uIntValue64: UInt64 = 0

  /// Swift equivalent: `SignedValue<Int32>`
  var sIntValue32: Int32 = 0

  /// Swift equivalent: `SignedValue<Int64>`
  var sIntValue64: Int64 = 0

  /// Swift equivalent: `FixedSize<UInt32>`
  var fIntValue32: UInt32 = 0

  /// Swift equivalent: `FixedSize<UInt64>`
  var fIntValue64: UInt64 = 0

  /// Swift equivalent: `FixedSize<Int32>`
  var sfIntValue32: Int32 = 0

  /// Swift equivalent: `FixedSize<Int64>`
  var sfIntValue64: Int64 = 0

  /// Swift equivalent: `Bool`
  var boolValue: Bool = false

  /// Swift equivalent: `String`
  var stringValue: String = String()

  /// Swift equivalent: `Data`
  var dataValue: Data = Data()

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct FieldNumberTest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var low: Bool = false

  var high: Bool = false

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

struct EnumContainer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var selection: EnumContainer.Selection = .default

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum Selection: SwiftProtobuf.Enum {
    typealias RawValue = Int
    case `default` // = 0
    case one // = 1
    case UNRECOGNIZED(Int)

    init() {
      self = .default
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .default
      case 1: self = .one
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .default: return 0
      case .one: return 1
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}
}

#if swift(>=4.2)

extension EnumContainer.Selection: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [EnumContainer.Selection] = [
    .default,
    .one,
  ]
}

#endif  // swift(>=4.2)

struct OneOfContainer {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  var alternatives: OneOfContainer.OneOf_Alternatives? = nil

  var integer: Int64 {
    get {
      if case .integer(let v)? = alternatives {return v}
      return 0
    }
    set {alternatives = .integer(newValue)}
  }

  var text: String {
    get {
      if case .text(let v)? = alternatives {return v}
      return String()
    }
    set {alternatives = .text(newValue)}
  }

  var unknownFields = SwiftProtobuf.UnknownStorage()

  enum OneOf_Alternatives: Equatable {
    case integer(Int64)
    case text(String)

  #if !swift(>=4.1)
    static func ==(lhs: OneOfContainer.OneOf_Alternatives, rhs: OneOfContainer.OneOf_Alternatives) -> Bool {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch (lhs, rhs) {
      case (.integer, .integer): return {
        guard case .integer(let l) = lhs, case .integer(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      case (.text, .text): return {
        guard case .text(let l) = lhs, case .text(let r) = rhs else { preconditionFailure() }
        return l == r
      }()
      default: return false
      }
    }
  #endif
  }

  init() {}
}

#if swift(>=5.5) && canImport(_Concurrency)
extension SimpleStruct: @unchecked Sendable {}
extension WrappedContainer: @unchecked Sendable {}
extension Outer: @unchecked Sendable {}
extension Outer2: @unchecked Sendable {}
extension MapContainer: @unchecked Sendable {}
extension PrimitiveTypesContainer: @unchecked Sendable {}
extension FieldNumberTest: @unchecked Sendable {}
extension EnumContainer: @unchecked Sendable {}
extension EnumContainer.Selection: @unchecked Sendable {}
extension OneOfContainer: @unchecked Sendable {}
extension OneOfContainer.OneOf_Alternatives: @unchecked Sendable {}
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

extension PrimitiveTypesContainer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "PrimitiveTypesContainer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "doubleValue"),
    2: .same(proto: "floatValue"),
    3: .same(proto: "intValue32"),
    4: .same(proto: "intValue64"),
    5: .same(proto: "uIntValue32"),
    6: .same(proto: "uIntValue64"),
    7: .same(proto: "sIntValue32"),
    8: .same(proto: "sIntValue64"),
    9: .same(proto: "fIntValue32"),
    10: .same(proto: "fIntValue64"),
    11: .same(proto: "sfIntValue32"),
    12: .same(proto: "sfIntValue64"),
    13: .same(proto: "boolValue"),
    14: .same(proto: "stringValue"),
    15: .same(proto: "dataValue"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularDoubleField(value: &self.doubleValue) }()
      case 2: try { try decoder.decodeSingularFloatField(value: &self.floatValue) }()
      case 3: try { try decoder.decodeSingularInt32Field(value: &self.intValue32) }()
      case 4: try { try decoder.decodeSingularInt64Field(value: &self.intValue64) }()
      case 5: try { try decoder.decodeSingularUInt32Field(value: &self.uIntValue32) }()
      case 6: try { try decoder.decodeSingularUInt64Field(value: &self.uIntValue64) }()
      case 7: try { try decoder.decodeSingularSInt32Field(value: &self.sIntValue32) }()
      case 8: try { try decoder.decodeSingularSInt64Field(value: &self.sIntValue64) }()
      case 9: try { try decoder.decodeSingularFixed32Field(value: &self.fIntValue32) }()
      case 10: try { try decoder.decodeSingularFixed64Field(value: &self.fIntValue64) }()
      case 11: try { try decoder.decodeSingularSFixed32Field(value: &self.sfIntValue32) }()
      case 12: try { try decoder.decodeSingularSFixed64Field(value: &self.sfIntValue64) }()
      case 13: try { try decoder.decodeSingularBoolField(value: &self.boolValue) }()
      case 14: try { try decoder.decodeSingularStringField(value: &self.stringValue) }()
      case 15: try { try decoder.decodeSingularBytesField(value: &self.dataValue) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.doubleValue != 0 {
      try visitor.visitSingularDoubleField(value: self.doubleValue, fieldNumber: 1)
    }
    if self.floatValue != 0 {
      try visitor.visitSingularFloatField(value: self.floatValue, fieldNumber: 2)
    }
    if self.intValue32 != 0 {
      try visitor.visitSingularInt32Field(value: self.intValue32, fieldNumber: 3)
    }
    if self.intValue64 != 0 {
      try visitor.visitSingularInt64Field(value: self.intValue64, fieldNumber: 4)
    }
    if self.uIntValue32 != 0 {
      try visitor.visitSingularUInt32Field(value: self.uIntValue32, fieldNumber: 5)
    }
    if self.uIntValue64 != 0 {
      try visitor.visitSingularUInt64Field(value: self.uIntValue64, fieldNumber: 6)
    }
    if self.sIntValue32 != 0 {
      try visitor.visitSingularSInt32Field(value: self.sIntValue32, fieldNumber: 7)
    }
    if self.sIntValue64 != 0 {
      try visitor.visitSingularSInt64Field(value: self.sIntValue64, fieldNumber: 8)
    }
    if self.fIntValue32 != 0 {
      try visitor.visitSingularFixed32Field(value: self.fIntValue32, fieldNumber: 9)
    }
    if self.fIntValue64 != 0 {
      try visitor.visitSingularFixed64Field(value: self.fIntValue64, fieldNumber: 10)
    }
    if self.sfIntValue32 != 0 {
      try visitor.visitSingularSFixed32Field(value: self.sfIntValue32, fieldNumber: 11)
    }
    if self.sfIntValue64 != 0 {
      try visitor.visitSingularSFixed64Field(value: self.sfIntValue64, fieldNumber: 12)
    }
    if self.boolValue != false {
      try visitor.visitSingularBoolField(value: self.boolValue, fieldNumber: 13)
    }
    if !self.stringValue.isEmpty {
      try visitor.visitSingularStringField(value: self.stringValue, fieldNumber: 14)
    }
    if !self.dataValue.isEmpty {
      try visitor.visitSingularBytesField(value: self.dataValue, fieldNumber: 15)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: PrimitiveTypesContainer, rhs: PrimitiveTypesContainer) -> Bool {
    if lhs.doubleValue != rhs.doubleValue {return false}
    if lhs.floatValue != rhs.floatValue {return false}
    if lhs.intValue32 != rhs.intValue32 {return false}
    if lhs.intValue64 != rhs.intValue64 {return false}
    if lhs.uIntValue32 != rhs.uIntValue32 {return false}
    if lhs.uIntValue64 != rhs.uIntValue64 {return false}
    if lhs.sIntValue32 != rhs.sIntValue32 {return false}
    if lhs.sIntValue64 != rhs.sIntValue64 {return false}
    if lhs.fIntValue32 != rhs.fIntValue32 {return false}
    if lhs.fIntValue64 != rhs.fIntValue64 {return false}
    if lhs.sfIntValue32 != rhs.sfIntValue32 {return false}
    if lhs.sfIntValue64 != rhs.sfIntValue64 {return false}
    if lhs.boolValue != rhs.boolValue {return false}
    if lhs.stringValue != rhs.stringValue {return false}
    if lhs.dataValue != rhs.dataValue {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension FieldNumberTest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "FieldNumberTest"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "low"),
    536870911: .same(proto: "high"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularBoolField(value: &self.low) }()
      case 536870911: try { try decoder.decodeSingularBoolField(value: &self.high) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.low != false {
      try visitor.visitSingularBoolField(value: self.low, fieldNumber: 1)
    }
    if self.high != false {
      try visitor.visitSingularBoolField(value: self.high, fieldNumber: 536870911)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: FieldNumberTest, rhs: FieldNumberTest) -> Bool {
    if lhs.low != rhs.low {return false}
    if lhs.high != rhs.high {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension EnumContainer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "EnumContainer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "selection"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularEnumField(value: &self.selection) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.selection != .default {
      try visitor.visitSingularEnumField(value: self.selection, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: EnumContainer, rhs: EnumContainer) -> Bool {
    if lhs.selection != rhs.selection {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension EnumContainer.Selection: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "DEFAULT"),
    1: .same(proto: "ONE"),
  ]
}

extension OneOfContainer: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = "OneOfContainer"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "integer"),
    2: .same(proto: "text"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try {
        var v: Int64?
        try decoder.decodeSingularInt64Field(value: &v)
        if let v = v {
          if self.alternatives != nil {try decoder.handleConflictingOneOf()}
          self.alternatives = .integer(v)
        }
      }()
      case 2: try {
        var v: String?
        try decoder.decodeSingularStringField(value: &v)
        if let v = v {
          if self.alternatives != nil {try decoder.handleConflictingOneOf()}
          self.alternatives = .text(v)
        }
      }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    switch self.alternatives {
    case .integer?: try {
      guard case .integer(let v)? = self.alternatives else { preconditionFailure() }
      try visitor.visitSingularInt64Field(value: v, fieldNumber: 1)
    }()
    case .text?: try {
      guard case .text(let v)? = self.alternatives else { preconditionFailure() }
      try visitor.visitSingularStringField(value: v, fieldNumber: 2)
    }()
    case nil: break
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: OneOfContainer, rhs: OneOfContainer) -> Bool {
    if lhs.alternatives != rhs.alternatives {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
