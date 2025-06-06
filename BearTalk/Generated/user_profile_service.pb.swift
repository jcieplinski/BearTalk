// DO NOT EDIT.
// swift-format-ignore-file
// swiftlint:disable all
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: user_profile_service.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

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

public struct Mobilegateway_Protos_PhoneNumber: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var type: String = String()

  public var number: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Mobilegateway_Protos_UserProfile: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var firstName: String = String()

  public var lastName: String = String()

  public var email: String = String()

  public var locale: String = String()

  public var photoURL: String {
    get {return _photoURL ?? String()}
    set {_photoURL = newValue}
  }
  /// Returns true if `photoURL` has been explicitly set.
  public var hasPhotoURL: Bool {return self._photoURL != nil}
  /// Clears the value of `photoURL`. Subsequent reads from it will return its default value.
  public mutating func clearPhotoURL() {self._photoURL = nil}

  public var address: String = String()

  public var city: String = String()

  public var state: String = String()

  public var postalCode: String = String()

  public var country: String = String()

  public var phones: [Mobilegateway_Protos_PhoneNumber] = []

  public var preferredName: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _photoURL: String? = nil
}

public struct Mobilegateway_Protos_GetUserProfileRequest: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Mobilegateway_Protos_GetUserProfileResponse: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var profile: Mobilegateway_Protos_UserProfile {
    get {return _profile ?? Mobilegateway_Protos_UserProfile()}
    set {_profile = newValue}
  }
  /// Returns true if `profile` has been explicitly set.
  public var hasProfile: Bool {return self._profile != nil}
  /// Clears the value of `profile`. Subsequent reads from it will return its default value.
  public mutating func clearProfile() {self._profile = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _profile: Mobilegateway_Protos_UserProfile? = nil
}

public struct Mobilegateway_Protos_SetUserProfileRequest: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var firstName: String = String()

  public var lastName: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Mobilegateway_Protos_SetUserProfileResponse: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var profile: Mobilegateway_Protos_UserProfile {
    get {return _profile ?? Mobilegateway_Protos_UserProfile()}
    set {_profile = newValue}
  }
  /// Returns true if `profile` has been explicitly set.
  public var hasProfile: Bool {return self._profile != nil}
  /// Clears the value of `profile`. Subsequent reads from it will return its default value.
  public mutating func clearProfile() {self._profile = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _profile: Mobilegateway_Protos_UserProfile? = nil
}

public struct Mobilegateway_Protos_UploadUserProfilePhotoRequest: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var photoBytes: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Mobilegateway_Protos_UploadUserProfilePhotoResponse: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var photoURL: String = String()

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Mobilegateway_Protos_ReferralHistoryApiRequest: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

public struct Mobilegateway_Protos_ReferralHistoryApiResponse: Sendable {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}
}

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "mobilegateway.protos"

extension Mobilegateway_Protos_PhoneNumber: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".PhoneNumber"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "type"),
    2: .same(proto: "number"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.type) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.number) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.type.isEmpty {
      try visitor.visitSingularStringField(value: self.type, fieldNumber: 1)
    }
    if !self.number.isEmpty {
      try visitor.visitSingularStringField(value: self.number, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_PhoneNumber, rhs: Mobilegateway_Protos_PhoneNumber) -> Bool {
    if lhs.type != rhs.type {return false}
    if lhs.number != rhs.number {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_UserProfile: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".UserProfile"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "first_name"),
    2: .standard(proto: "last_name"),
    3: .same(proto: "email"),
    4: .same(proto: "locale"),
    5: .standard(proto: "photo_url"),
    6: .same(proto: "address"),
    7: .same(proto: "city"),
    8: .same(proto: "state"),
    9: .standard(proto: "postal_code"),
    10: .same(proto: "country"),
    11: .same(proto: "phones"),
    12: .standard(proto: "preferred_name"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.firstName) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.lastName) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.email) }()
      case 4: try { try decoder.decodeSingularStringField(value: &self.locale) }()
      case 5: try { try decoder.decodeSingularStringField(value: &self._photoURL) }()
      case 6: try { try decoder.decodeSingularStringField(value: &self.address) }()
      case 7: try { try decoder.decodeSingularStringField(value: &self.city) }()
      case 8: try { try decoder.decodeSingularStringField(value: &self.state) }()
      case 9: try { try decoder.decodeSingularStringField(value: &self.postalCode) }()
      case 10: try { try decoder.decodeSingularStringField(value: &self.country) }()
      case 11: try { try decoder.decodeRepeatedMessageField(value: &self.phones) }()
      case 12: try { try decoder.decodeSingularStringField(value: &self.preferredName) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.firstName.isEmpty {
      try visitor.visitSingularStringField(value: self.firstName, fieldNumber: 1)
    }
    if !self.lastName.isEmpty {
      try visitor.visitSingularStringField(value: self.lastName, fieldNumber: 2)
    }
    if !self.email.isEmpty {
      try visitor.visitSingularStringField(value: self.email, fieldNumber: 3)
    }
    if !self.locale.isEmpty {
      try visitor.visitSingularStringField(value: self.locale, fieldNumber: 4)
    }
    try { if let v = self._photoURL {
      try visitor.visitSingularStringField(value: v, fieldNumber: 5)
    } }()
    if !self.address.isEmpty {
      try visitor.visitSingularStringField(value: self.address, fieldNumber: 6)
    }
    if !self.city.isEmpty {
      try visitor.visitSingularStringField(value: self.city, fieldNumber: 7)
    }
    if !self.state.isEmpty {
      try visitor.visitSingularStringField(value: self.state, fieldNumber: 8)
    }
    if !self.postalCode.isEmpty {
      try visitor.visitSingularStringField(value: self.postalCode, fieldNumber: 9)
    }
    if !self.country.isEmpty {
      try visitor.visitSingularStringField(value: self.country, fieldNumber: 10)
    }
    if !self.phones.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.phones, fieldNumber: 11)
    }
    if !self.preferredName.isEmpty {
      try visitor.visitSingularStringField(value: self.preferredName, fieldNumber: 12)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_UserProfile, rhs: Mobilegateway_Protos_UserProfile) -> Bool {
    if lhs.firstName != rhs.firstName {return false}
    if lhs.lastName != rhs.lastName {return false}
    if lhs.email != rhs.email {return false}
    if lhs.locale != rhs.locale {return false}
    if lhs._photoURL != rhs._photoURL {return false}
    if lhs.address != rhs.address {return false}
    if lhs.city != rhs.city {return false}
    if lhs.state != rhs.state {return false}
    if lhs.postalCode != rhs.postalCode {return false}
    if lhs.country != rhs.country {return false}
    if lhs.phones != rhs.phones {return false}
    if lhs.preferredName != rhs.preferredName {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_GetUserProfileRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GetUserProfileRequest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    // Load everything into unknown fields
    while try decoder.nextFieldNumber() != nil {}
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_GetUserProfileRequest, rhs: Mobilegateway_Protos_GetUserProfileRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_GetUserProfileResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".GetUserProfileResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "profile"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._profile) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._profile {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_GetUserProfileResponse, rhs: Mobilegateway_Protos_GetUserProfileResponse) -> Bool {
    if lhs._profile != rhs._profile {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_SetUserProfileRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".SetUserProfileRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "first_name"),
    2: .standard(proto: "last_name"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.firstName) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.lastName) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.firstName.isEmpty {
      try visitor.visitSingularStringField(value: self.firstName, fieldNumber: 1)
    }
    if !self.lastName.isEmpty {
      try visitor.visitSingularStringField(value: self.lastName, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_SetUserProfileRequest, rhs: Mobilegateway_Protos_SetUserProfileRequest) -> Bool {
    if lhs.firstName != rhs.firstName {return false}
    if lhs.lastName != rhs.lastName {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_SetUserProfileResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".SetUserProfileResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "profile"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._profile) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._profile {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_SetUserProfileResponse, rhs: Mobilegateway_Protos_SetUserProfileResponse) -> Bool {
    if lhs._profile != rhs._profile {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_UploadUserProfilePhotoRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".UploadUserProfilePhotoRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "photo_bytes"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.photoBytes) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.photoBytes.isEmpty {
      try visitor.visitSingularStringField(value: self.photoBytes, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_UploadUserProfilePhotoRequest, rhs: Mobilegateway_Protos_UploadUserProfilePhotoRequest) -> Bool {
    if lhs.photoBytes != rhs.photoBytes {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_UploadUserProfilePhotoResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".UploadUserProfilePhotoResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "photo_url"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.photoURL) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if !self.photoURL.isEmpty {
      try visitor.visitSingularStringField(value: self.photoURL, fieldNumber: 1)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_UploadUserProfilePhotoResponse, rhs: Mobilegateway_Protos_UploadUserProfilePhotoResponse) -> Bool {
    if lhs.photoURL != rhs.photoURL {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_ReferralHistoryApiRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ReferralHistoryApiRequest"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    // Load everything into unknown fields
    while try decoder.nextFieldNumber() != nil {}
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_ReferralHistoryApiRequest, rhs: Mobilegateway_Protos_ReferralHistoryApiRequest) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Mobilegateway_Protos_ReferralHistoryApiResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ReferralHistoryApiResponse"
  public static let _protobuf_nameMap = SwiftProtobuf._NameMap()

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    // Load everything into unknown fields
    while try decoder.nextFieldNumber() != nil {}
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Mobilegateway_Protos_ReferralHistoryApiResponse, rhs: Mobilegateway_Protos_ReferralHistoryApiResponse) -> Bool {
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
